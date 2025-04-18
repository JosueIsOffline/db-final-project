const reservationService = require("../services/reservation.service");
const Logger = require("../utils/logger");

/**
 * Create a new reservation
 * @param {Request} req Express request object
 * @param {Response} res Express response object
 */
const createReservation = async (req, res) => {
  try {
    const { storeId, productId, quantity, customerInfo, notes } = req.body;

    if (!storeId || !productId || !quantity) {
      return res.status(400).json({
        message: "Store ID, Product ID and Quantity are required",
      });
    }

    if (quantity <= 0) {
      return res.status(400).json({
        message: "Quantity must be greater than 0",
      });
    }

    const reservationData = await reservationService.createReservation({
      storeId,
      productId,
      quantity,
      customerInfo,
      notes,
    });

    res.status(201).json({
      success: true,
      message: "Reservation created successfully",
      data: reservationData,
    });
  } catch (error) {
    Logger.log(`Error creating reservation: ${error.message}`, "error");
    res.status(500).json({
      success: false,
      message: "Error creating reservation",
      error: error.message,
    });
  }
};

/**
 * Get a reservation by confirmation code
 * @param {Request} req Express request object
 * @param {Response} res Express response object
 */
const getReservationByCode = async (req, res) => {
  try {
    const { confirmationCode } = req.params;
    
    if (!confirmationCode) {
      return res.status(400).json({
        success: false,
        message: "Confirmation code is required",
      });
    }

    const reservation = await reservationService.getReservationByCode(
      confirmationCode.toUpperCase()
    );

    res.status(200).json({
      success: true,
      message: "Reservation retrieved successfully",
      data: reservation,
    });
  } catch (error) {
    Logger.log(`Error getting reservation: ${error.message}`, "error");

    // Handle not found error specifically
    if (error.message === "Reservation not found") {
      return res.status(404).json({
        success: false,
        message: error.message,
      });
    }

    res.status(500).json({
      success: false,
      message: "Error getting reservation",
      error: error.message,
    });
  }
};

/**
 * Confirm a reservation
 * @param {Request} req Express request object
 * @param {Response} res Express response object
 */
const confirmReservation = async (req, res) => {
  try {
    const { confirmationCode } = req.params;

    if (!confirmationCode) {
      return res.status(400).json({
        success: false,
        message: "Confirmation code is required",
      });
    }

    const result = await reservationService.confirmReservation(
      confirmationCode.toUpperCase()
    );

    res.status(200).json({
      success: true,
      message: "Reservation confirmed successfully",
      data: result,
    });
  } catch (error) {
    Logger.error(`Error confirming reservation: ${error.message}`, "error");

    // Handle not found error specifically
    if (
      error.message.includes("cannot be confirmed") ||
      error.message === "Reservation not found" ||
      error.message === "Reservation has expired"
    ) {
      return res.status(400).json({
        success: false,
        message: error.message,
      });
    }

    res.status(500).json({
      success: false,
      message: "Error confirming reservation",
      error: error.message,
    });
  }
};

/**
 * Cancel a reservation
 * @param {Request} req Express request object
 * @param {Response} res Express response object
 */
const cancelReservation = async (req, res) => {
    try {
        const { confirmationCode } = req.params;
        const { reason } = req.body;

        if(!confirmationCode) {
            return res.status(400).json({
                success: false,
                message: "Confirmation code is required",
            });
        }

        result = await reservationService.cancelReservation(confirmationCode.toUpperCase(), reason);
    
        res.status(200).json({
            success: true,
            message: "Reservation cancelled successfully",
            data: result,
        });

    } catch (error) {
        Logger.error(`Error cancelling reservation: ${error.message}`);
        
        // Handle specific errors
        if (error.message.includes('cannot be cancelled') || 
            error.message === 'Reservation not found') {
            return res.status(400).json({
                success: false,
                message: error.message
            });
        }
        
        res.status(500).json({
            success: false,
            message: 'Error cancelling reservation',
            error: error.message
        });
    }
}

/**
 * Complete a reservation
 * @param {Request} req Express request object
 * @param {Response} res Express response object
 */
const completeReservation = async (req, res) => {
    try {
        const { confirmationCode } = req.params;
        if (!confirmationCode) {
            return res.status(400).json({
                success: false,
                message: "Confirmation code is required",
            });
        }

        const result = await reservationService.completeReservation(confirmationCode.toUpperCase());

        res.status(200).json({
            success: true,
            message: "Reservation completed successfully",
            data: result,
        });
    } catch (error) {
        Logger.error(`Error completing reservation: ${error.message}`);
        
        // Handle specific errors
        if (error.message.includes('cannot be completed') || 
            error.message === 'Reservation not found') {
            return res.status(400).json({
                success: false,
                message: error.message
            });
        }
        
        res.status(500).json({
            success: false,
            message: 'Error completing reservation',
            error: error.message
        });
    }
}

/**
 * Get active reservations with pagination
 * @param {Request} req Express request object
 * @param {Response} res Express response object
 */
const getActiveReservations = async (req, res) => {
    try {
        const { page, limit, storeId } = req.query;

        const result = await reservationService.getActiveReservations({
            page,
            limit,
            storeId
        })

        res.status(200).json({
            success: true,
            count: result.reservations.length,
            total: result.pagination.total,
            pagination: result.pagination,
            data: result.reservations
        })

    } catch (error) {
        Logger.error(`Error getting active reservations: ${error.message}`);
        res.status(500).json({
            success: false,
            message: 'Error retrieving active reservations',
            error: error.message
        });
    }
}

/**
 * Get customer reservations
 * @param {Request} req Express request object
 * @param {Response} res Express response object
 */
const getCustomerReservations = async (req, res) => {
    try {
        const { customerId } = req.params;
        if (!customerId) {
            return res.status(400).json({
                success: false,
                message: "Customer ID is required",
            });
        }

        const reservations = await reservationService.getCustomerReservations(customerId);

        res.status(200).json({
            success: true,
            count: reservations.length,
            data: reservations,
        });
    } catch (error) {
        Logger.error(`Error fetching customer reservations: ${error.message}`);
        res.status(500).json({
            success: false,
            message: 'Error fetching customer reservations',
            error: error.message
        });
    }
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
