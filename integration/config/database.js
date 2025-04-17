// SQL Server Configuration
const sqlConfig = {
  server: process.env.SQL_SERVER || 'localhost',
  database: process.env.SQL_DATABASE || 'RetailChainDB',
  options: {
    encrypt: false,
    trustServerCertificate: true,
    trustedConnection: true
  },
  drive: 'msnodesqlv8'
};


// MongoDB Configuration
const mongoURI = process.env.MONGO_URI || 'mongodb://localhost:27017/RetailChainDB';


module.exports = {
    sqlConfig,
    mongoURI,
}