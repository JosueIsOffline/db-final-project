const sql = require('mssql/msnodesqlv8');
const { sqlConfig }= require('../config/database');
const Logger = require('../utils/logger');

let sqlPool = null;

// SQL Server Connection Pool
const connectToSQLServer = async () => {
    const startTime = Date.now();
    try {
        sqlPool = await sql.connect(sqlConfig);
        const connectionTime = Date.now() - startTime;
        
        console.log("\n")
       
        Logger.log(`SQL Server connection established successfully in ${connectionTime}ms`, 'success');
        Logger.log(`Server: ${sqlConfig.server}`, 'info');
        Logger.log(`Database: ${sqlConfig.database}`, 'info');
        //Logger.log(`Connection Pool Size: ${sqlPool.pool.max} connections`, 'info');
        
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

// Ejecutar consultas SQL
const executeSQL = async (query, params = []) => {
    try {
        // Asegurarse de que la conexión está establecida
        if (!sqlPool) {
            sqlPool = await connectToSQLServer();
        }
        
        const request = sqlPool.request();
        
        // Añadir parámetros si se proporcionan
        if (params && params.length > 0) {
            params.forEach((param, index) => {
                request.input(`param${index}`, param);
            });
        }
        
        const result = await request.query(query);
        return result;
    } catch (err) {
        Logger.log(`Error executing SQL query: ${err.message}`, "error");
        Logger.log(`Query: ${query}`, "debug");
        Logger.log(`Parameters: ${JSON.stringify(params)}`, "debug");
        throw err;
    }
};

module.exports ={ connectToSQLServer, executeSQL };