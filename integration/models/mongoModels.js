const mongoose = require('mongoose');

// Schema para cliente (información extendida)
const CustomerSchema = new mongoose.Schema({
  // ID del cliente en SQL Server (para vincular los datos)
  sqlCustomerId: {
    type: Number,
    required: true,
    unique: true
  },
  // Información básica
  firstName: String,
  lastName: String,
  email: String,
  // Preferencias de compra
  preferences: {
    preferredCategories: [String],
    preferredStores: [Number],
    favoriteProducts: [Number],
    newsletterSubscribed: { type: Boolean, default: false },
    communicationPreferences: {
      email: { type: Boolean, default: true },
      sms: { type: Boolean, default: false },
      pushNotifications: { type: Boolean, default: false }
    }
  },
  // Historial de acciones
  lastActivity: Date,
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
}, { timestamps: true });

// Schema para reservas de productos
const ReservationSchema = new mongoose.Schema({
  // Información del cliente
  customerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Customer',
    required: false // Puede ser anónimo
  },
  sqlCustomerId: Number,
  customerName: String,
  customerEmail: String,
  customerPhone: String,

  // Información de la tienda
  storeId: {
    type: Number,
    required: true
  },
  storeName: String,

  // Información del producto
  productId: {
    type: Number,
    required: true
  },
  productName: String,
  productSku: String,
  
  // Detalles de la reserva
  quantity: {
    type: Number,
    required: true,
    min: 1
  },
  unitPrice: Number,
  reservationDate: {
    type: Date,
    default: Date.now
  },
  expiryDate: {
    type: Date,
    required: true
  },
  status: {
    type: String,
    enum: ['PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED', 'EXPIRED'],
    default: 'PENDING'
  },
  confirmationCode: {
    type: String,
    required: true,
    unique: true
  },
  // Información adicional
  notes: String,
  
  // Seguimiento
  statusHistory: [{
    status: String,
    date: { type: Date, default: Date.now },
    comment: String
  }],
  
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
}, { timestamps: true });

// Índices para mejorar el rendimiento de consultas
CustomerSchema.index({ email: 1 });
ReservationSchema.index({ customerId: 1 });
ReservationSchema.index({ status: 1 });
ReservationSchema.index({ storeId: 1, productId: 1 });
ReservationSchema.index({ expiryDate: 1, status: 1 });

// Método para actualizar el estado de reservas expiradas
ReservationSchema.statics.updateExpiredReservations = async function() {
  const result = await this.updateMany(
    { 
      expiryDate: { $lt: new Date() },
      status: 'PENDING'
    },
    { 
      $set: { 
        status: 'EXPIRED',
        updatedAt: new Date()
      },
      $push: { 
        statusHistory: {
          status: 'EXPIRED',
          date: new Date(),
          comment: 'Reserva expirada automáticamente'
        }
      }
    }
  );
  
  return result;
};

// Crear modelos
const Customer = mongoose.model('Customer', CustomerSchema);
const Reservation = mongoose.model('Reservation', ReservationSchema);

module.exports = {
  Customer,
  Reservation
};