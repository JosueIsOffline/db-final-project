const { Customer, Reservation } = require("../models/mongoModels");
const { Inventory, Product, Store } = require("../models/sqlModels");
const crypto = require("crypto");

//TODO: Refactor services file  to export one single object with all functions

/**
 * Create a new reservation
 * @param {Object} data - Reservation data
 * return {Object} - Reservation details
 */
const createReservation = async (data) => {
  const { storeId, productId, quantity, customerInfo, notes } = data;

  const availability = await Inventory.checkAvailability(storeId, productId);
  if (!availability.available || availability.quantityInStock < quantity) {
    throw new Error(
      "Insufficient stock for this product in the selected store"
    );
  }

  const product = await Product.getProductById(productId);
  const store = await Store.getStoreById(storeId);
  if (!product || !store) {
    throw new Error("Product or store not found");
  }

  const confirmationCode = crypto.randomBytes(3).toString("hex").toUpperCase();

  const expiryDate = new Date();
  expiryDate.setHours(expiryDate.getHours() + 24); // Set to expire in 24 hours

  const reservation = new Reservation({
    storeId,
    storeName: store.StoreName,
    productId,
    productName: product.ProductName,
    productSku: product.SKU,
    quantity,
    unitPrice: product.RetailPrice,
    expiryDate,
    confirmationCode,
    notes,
    statusHistory: [
      {
        status: "PENDING",
        date: new Date(),
        comment: "Reservation created",
      },
    ],
  });

  if (customerInfo) {
    reservation.customerName = customerInfo.name || "";
    reservation.customerEmail = customerInfo.email || "";
    reservation.customerPhone = customerInfo.phone || "";

    if (customerInfo.sqlCustomerId) {
      reservation.sqlCustomerId = customerInfo.sqlCustomerId;

      let customer = await Customer.findOne({
        sqlCustomerId: customerInfo.sqlCustomerId,
      });
      if (customer) {
        Logger.log(`Cliente encontrado en MongoDB: ${customer._id}`, "debug");
        reservation.customerId = customer._id;
      } else {
        Logger.log("Cliente no encontrado, creando nuevo registro");
        customer = new Customer({
          sqlCustomerId: customerInfo.sqlCustomerId,
          firstName: customerInfo.name?.split(" ")[0] || "",
          lastName: customerInfo.name?.split(" ").slice(1).join(" ") || "",
          email: customerInfo.email,
          lastActivity: new Date(),
          preferences: {
            preferredCategories: [],
            preferredStores: [],
            newsletterSubscribed: false,
            communicationPreferences: {
              email: true,
              sms: false,
              pushNotifications: false,
            },
          },
        });
        const savedCustomer = await customer.save();
        Logger.log(
          `Cliente guardado exitosamente: ${savedCustomer._id}`,
          "debug"
        );
        reservation.customerId = customer._id;
      }
    }
  }

  await reservation.save();

  await Inventory.updateInventory(storeId, productId, -quantity);

  return {
    reservationId: reservation._id,
    confirmationCode,
    expiryDate,
    productName: product.ProductName,
    storeName: store.StoreName,
    quantity,
    unitPrice: product.RetailPrice,
    totalPrice: product.RetailPrice * quantity,
    status: "PENDING",
  };
};

/**
 * Get a reservation by confirmation code
 * @param {string} code - Confirmation code
 * @return {Object} - Reservation details
 */
const getReservationByCode = async (code) => {
  if (!code) throw new Error("Confirmation code is required");

  const reservation = await Reservation.findOne({
    confirmationCode: code.toUpperCase(),
  });
  
  if (!reservation) throw new Error("Reservation not found");

  return reservation;
};

/**
 * Confirm a reservation
 * @param {string} code Confirmation code
 * @return {Object} - Updated reservation details
 */
const confirmReservation = async (code) => {
  const reservation = await getReservationByCode(code);

  if (reservation.status !== "PENDING")
    throw new Error(
      `Reservation cannot be confirmed, current status: ${reservation.status}`
    );

  // Check if reservation has expired
  if (new Date() > reservation.expiryDate) {
    reservation.status = "EXPIRED";
    reservation.statusHistory.push({
      status: "EXPIRED",
      date: new Date(),
      comment: "Reservation expired",
    });
    await reservation.save();

    await Inventory.updateInventory(
      reservation.storeId,
      reservation.productId,
      reservation.quantity
    );

    throw new Error("Reservation has expired");
  }

  // Update reservation status to CONFIRMED
  reservation.status = "CONFIRMED";
  reservation.statusHistory.push({
    status: "CONFIRMED",
    date: new Date(),
    comment: "Reservation confirmed",
  })

  await reservation.save();

  return {
    reservationId: reservation._id,
    confirmationCode: reservation.confirmationCode,
    status: reservation.status,
    productName: reservation.productName,
    quantity: reservation.quantity,
    storeName: reservation.storeName,
  }
};

/**
 * Cancel a reservation
 * @param {string} code - Confirmation code
 * @param { string} reason - Cancellation reason
 * @return {Object} - Updated reservation details
 */
const cancelReservation = async (code, reason = "Cancelled by customer") => {
  const reservation = await getReservationByCode(code);

  // check if reservation is already cancelled
  if (["CANCELLED", "COMPLETED", "EXPIRED"].includes(reservation.status)) {
    throw new Error("Reservation already cancelled or expired");
  }

  // update reservation status
  reservation.status = "CANCELLED";
  reservation.statusHistory.push({
    status: "CANCELLED",
    date: new Date(),
    comment: reason,
  });

  await reservation.save();

  await Inventory.updateInventory(
    reservation.storeId,
    reservation.productId,
    reservation.quantity
  );

  return {
    reservationId: reservation._id,
    confirmationCode: reservation.confirmationCode,
    status: reservation.status,
    message: "Reservation cancelled successfully",
  };
};

/**
 * Complete a reservation (product picked up)
 * @param {string} code - Confirmation code
 * @return {Object} - Updated reservation details
 */
const completeReservation = async (code) => {
    const reservation = await getReservationByCode(code);

    // Check if reservation can be COMPLETED
    if( reservation.status !== "CONFIRMED" && reservation.status !== "PENDING") {
        throw new Error(`Reservation cannot be completed, current status: ${reservation.status}`);
    }

    // Update status to COMPLETED
    reservation.status = "COMPLETED";
    reservation.statusHistory.push({
        status: "COMPLETED",
        date: new Date(),
        comment: "Reservation completed",
    });

    await reservation.save();

    return {
        reservationId: reservation._id,
        confirmationCode: reservation.confirmationCode,
        status: reservation.status,
        completedDate: new Date(),
        message: "Reservation completed successfully",
    }
}

/**
 * Get active reservations with pagination
 * @param {Object} options Pagination options
 * @return {Object} Reservations with pagination info
 */
const getActiveReservations = async (options = {}) => {
    // Get pagination options
    const page = parseInt(options.page) || 1;
    const limit = parseInt(options.limit) || 10;
    const skip = (page - 1) * limit;

    // Update expitred reservations
    await Reservation.updateExpiredReservations()

    // Filter by store reservations
    const filter = { status: { $in: ["PENDING", "CONFIRMED"] } };
    if (options.storeId) {
        filter.storeId = parseInt(options.storeId);
    }

    // Count total records 
    const total = await Reservation.countDocuments(filter)

    // Get reservations
    const reservations = await Reservation.find(filter)
        .skip(skip)
        .limit(limit)
        .sort({ createdAt: -1 })
        
    return {
        reservations,
        pagination: {
            page,
            limit,
            total,
            pages: Math.ceil(total / limit)
        }
    }
}

/**
 * Get reservation by customer ID
 * @patam {number} customerId SQL customer ID
 * @return {Array} Customer reservations
 */
const getCustomerReservations = async (customerId) => {
    if(!customerId) throw new Error("Customer ID is required")

    // Update expired reservations firts
    await Reservation.updateExpiredReservations()
    
    const reservations  = await Reservation.find({ sqlCustomerId: customerId })
        .sort({ createdAt: -1 })
        
    return reservations
}



module.exports = {
    createReservation,
    getReservationByCode,
    confirmReservation,
    cancelReservation,
    completeReservation,
    getActiveReservations,
    getCustomerReservations,
  };
