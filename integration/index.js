const express = require('express');
const app = express();

const cors = require('cors');

app.logger = require('./utils/logger'); // Logger instance

const { router } = require('./routes')


// Database connections
const { connectToSQLServer } = require('./databases/sqlClient');
const connectToMongoDB = require('./databases/mongoClient');

// Setup Swagger documentation
const { setupSwagger } = require('./config/swagger');

app.use(express.json());

setupSwagger(app); // Setup Swagger documentation



app.use(cors())
app.use("/", router)

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
     connectToSQLServer()
     connectToMongoDB()
    
    app.logger.log(`Server is starting on port ${PORT}`, 'success');
    app.logger.log(`Server is running on http://localhost:${PORT}`, 'info');
    app.logger.log(`API documentation running on http://localhost:${PORT}/api-docs`, 'debug');

})
