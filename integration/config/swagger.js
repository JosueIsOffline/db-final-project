const swaggerJsDoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');
require('dotenv').config();

const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'API de Integración Retail',
      version: '1.0.0',
      description: 'API que integra SQL Server y MongoDB para reserva de productos',
      contact: {
        name: 'Soporte API',
        email: 'soporte@ejemplo.com'
      }
    },
    servers: [
      {
        url: `${process.env.API_URL || 'http://localhost:3000/api'}`,
        description: 'Servidor de desarrollo'
      }
    ]
  },
  apis: ['./routes/**/*.js'] // Rutas a los archivos con anotaciones de Swagger
};

const swaggerDocs = swaggerJsDoc(swaggerOptions);

const setupSwagger = (app) => {
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));
};

module.exports = { setupSwagger };