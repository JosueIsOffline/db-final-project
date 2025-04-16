const sql = require('mssql/msnodesqlv8');
const mongoose = require('mongoose');
const Logger = require('../utils/logger');


// SQL Server Configuration
const sqlConfig = {
  server: 'ASUSROG\\SQLEXPRESS3',
  database: 'RetailChainDB',
  options: {
    encrypt: false,
    trustServerCertificate: true,
    trustedConnection: true
  },
  drive: 'msnodesqlv8'
};

// SQL Server Connection Pool
const getConnection = async () => {
    const startTime = Date.now();
    try {
        const sqlPool = await sql.connect(sqlConfig);
        const connectionTime = Date.now() - startTime;
       
        Logger.log(`SQL Server connection established successfully in ${connectionTime}ms`, 'success');
        Logger.log(`Server: ${sqlConfig.server}`, 'info');
        Logger.log(`Database: ${sqlConfig.database}`, 'info');
        Logger.log(`Connection Pool Size: ${sqlPool.pool.max} connections`, 'info');
        
        return sqlPool;
    } catch (error) {
        Logger.log(`SQL Server connection failed: ${error.message}`, "error");
        Logger.log('Connection details:', {
            server: sqlConfig.server,
            database: sqlConfig.database,
            fullError: error
        }, "debug");
        process.exit(1);
    }
}

// MongoDB Configuration
const mongoURI = process.env.MONGO_URI || 'mongodb://localhost:27017/RetailChainDB';

// MongoDB Connection
// const connectToMongoDB = async () => {
//   try {
//     await mongoose.connect(mongoURI);
//     console.log('✅ MongoDB connection established successfully');
//     console.log(`🔗 MongoDB URI: ${mongoURI.replace(/\/\/(.+):(.+)@/, '//***:***@')}`); // Hide credentials if present
//     console.log(`🗄️  Database: ${mongoURI.split('/').pop()}`);
//   } catch (error) {
//     console.error('❌ MongoDB connection failed:', error.message);
//     console.debug('Connection details:', {
//         uri: mongoURI.replace(/\/\/(.+):(.+)@/, '//***:***@'), // Hide credentials in logs
//         fullError: error
//     });
//     process.exit(1);
//   }
// };

module.exports = {
    getConnection
}