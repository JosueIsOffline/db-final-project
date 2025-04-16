// Cargar variables de entorno
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { setupSwagger } = require('./config/swagger');
const { connectToSQLServer, connectToMongoDB, getConnection } = require('./config/database');

// Importar rutas
// const productRoutes = require('./routes/products');
// const reservationRoutes = require('./routes/reservations');

// Configurar app
const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(express.json());

// Conectar a bases de datos
// connectToSQLServer();
// connectToMongoDB();
getConnection()

// Configurar Swagger
// setupSwagger(app);

// Rutas de la API
// app.use('/api/products', productRoutes);
// app.use('/api/reservations', reservationRoutes);

// Ruta base
app.get('/', (req, res) => {
  res.json({ 
    message: 'API de Integración Retail',
    docs: '/api-docs'
  });
});

// Middleware de errores
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Error en el servidor',
    error: process.env.NODE_ENV === 'production' ? null : err.message
  });
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`Servidor ejecutándose en el puerto ${PORT}`);
  console.log(`Documentación en http://localhost:${PORT}/api-docs`);
});