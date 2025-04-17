const sql = require('mssql/msnodesqlv8');
const mongoose = require('mongoose');
const { Customer } = require('./models/mongoModels'); // Asegúrate de que la ruta sea correcta

// Configuración SQL Server
const sqlConfig = {
  server: 'ASUSROG\\SQLEXPRESS3',
  database: 'RetailChainDB',
  options: {
    encrypt: false,
    trustServerCertificate: true,
    trustedConnection: true,
    requestTimeout: 60000, // Incrementar timeout a 60 segundos
    connectionTimeout: 60000 // Incrementar timeout de conexión
  },
  drive: 'msnodesqlv8'
};

// Configuración MongoDB
const mongoURI = 'mongodb+srv://josuehernandez2314:josue2314pro@cluster0.ydawrb3.mongodb.net/RetailChainDB?retryWrites=true&w=majority&appName=Cluster0'; // Cambia a la base de datos que estás usando

// Función para procesar clientes en lotes
async function syncCustomersInBatches(batchSize = 50) {
    console.log('Iniciando sincronización de clientes entre SQL Server y MongoDB...');
    
    let sqlPool;
    try {
      // Conectar a MongoDB
      await mongoose.connect(mongoURI);
      console.log('Conectado a MongoDB');
      const deleteResult = await Customer.deleteMany({});
      console.log(`Eliminados ${deleteResult.deletedCount} registros de clientes en MongoDB`);
      // Obtener el total de clientes para calcular el número de lotes
      sqlPool = await sql.connect(sqlConfig);
      console.log('Conectado a SQL Server');
      
      const countResult = await sqlPool.request().query('SELECT COUNT(*) as total FROM Sales.Customer');
      const totalCustomers = countResult.recordset[0].total;
      console.log(`Total de clientes a sincronizar: ${totalCustomers}`);
      
      // Procesar en lotes
      let offset = 0;
      let created = 0;
      let updated = 0;
      
      while (offset < totalCustomers) {
        console.log(`Procesando lote desde ${offset} hasta ${offset + batchSize - 1}...`);
        
        // Reconectar a SQL Server si es necesario
        if (!sqlPool.connected) {
          console.log('Reconectando a SQL Server...');
          await sqlPool.close();
          sqlPool = await sql.connect(sqlConfig);
        }
        
        // Consultar el lote actual
        const query = `
          SELECT 
            CustomerID,
            FirstName,
            LastName,
            Email,
            Phone,
            Address,
            CityID,
            LoyaltyCardNumber,
            LoyaltyPoints,
            LoyaltyLevelID,
            BirthDate,
            Gender,
            IsActive,
            JoinDate,
            LastPurchaseDate
          FROM 
            Sales.Customer
          ORDER BY CustomerID
          OFFSET ${offset} ROWS
          FETCH NEXT ${batchSize} ROWS ONLY
        `;
        
        const result = await sqlPool.request().query(query);
        const customers = result.recordset;
        
        // Procesar el lote actual
        for (const sqlCustomer of customers) {
          try {
            // Buscar si ya existe en MongoDB
            let mongoCustomer = await Customer.findOne({ sqlCustomerId: sqlCustomer.CustomerID });
            
            if (mongoCustomer) {
              // Actualizar cliente existente
              mongoCustomer.firstName = sqlCustomer.FirstName;
              mongoCustomer.lastName = sqlCustomer.LastName;
              mongoCustomer.email = sqlCustomer.Email;
              mongoCustomer.phone = sqlCustomer.Phone;
              mongoCustomer.loyaltyCardNumber = sqlCustomer.LoyaltyCardNumber;
              mongoCustomer.loyaltyPoints = sqlCustomer.LoyaltyPoints;
              mongoCustomer.lastActivity = new Date();
              
              await mongoCustomer.save();
              updated++;
            } else {
              // Crear nuevo cliente
              const newCustomer = new Customer({
                sqlCustomerId: sqlCustomer.CustomerID,
                firstName: sqlCustomer.FirstName,
                lastName: sqlCustomer.LastName,
                email: sqlCustomer.Email,
                phone: sqlCustomer.Phone,
                loyaltyCardNumber: sqlCustomer.LoyaltyCardNumber,
                loyaltyPoints: sqlCustomer.LoyaltyPoints,
                birthDate: sqlCustomer.BirthDate,
                gender: sqlCustomer.Gender,
                isActive: sqlCustomer.IsActive === 1,
                lastActivity: new Date(),
                preferences: {
                  preferredCategories: [],
                  preferredStores: [],
                  newsletterSubscribed: Math.random() > 0.5,
                  communicationPreferences: {
                    email: true,
                    sms: Math.random() > 0.7,
                    pushNotifications: Math.random() > 0.8
                  }
                }
              });
              
              await newCustomer.save();
              created++;
            }
          } catch (customerError) {
            console.error(`Error procesando cliente ${sqlCustomer.CustomerID}:`, customerError);
          }
        }
        
        console.log(`Lote completado. Hasta ahora: ${created} creados, ${updated} actualizados.`);
        offset += batchSize;
        
        // Pequeña pausa entre lotes para evitar sobrecargar la conexión
        await new Promise(resolve => setTimeout(resolve, 1000));
      }
      
      console.log(`Sincronización completada: ${created} clientes creados, ${updated} clientes actualizados.`);
      
    } catch (error) {
      console.error('Error en la sincronización:', error);
    } finally {
      // Cerrar conexiones
      if (sqlPool) {
        await sqlPool.close();
      }
      await mongoose.disconnect();
      console.log('Conexiones cerradas');
    }
  }
  
  // Ejecutar la sincronización con lotes de 50 clientes
  syncCustomersInBatches(50)
    .then(() => console.log('Proceso finalizado'))
    .catch(err => console.error('Error en el proceso principal:', err));