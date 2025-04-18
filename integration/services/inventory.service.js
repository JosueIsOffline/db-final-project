const { executeSQL } = require("../databases/sqlClient")
const Logger = require("../utils/logger")

/**
 * Service for inventory operations
 */

const inventoryService = {
    /**
   * Get product inventory across all stores
   * @param {number} limit Maximum number of records to return
   * @returns {Promise<Array>} Inventory records
   */
  getAllInventory: async (limit = 100) => {
    try {
        const query = `
         SELECT TOP ${limit}
          i.InventoryID,
          i.StoreID,
          s.StoreName,
          i.ProductID,
          p.ProductName,
          p.SKU,
          p.Barcode,
          i.QuantityInStock,
          i.StockDate,
          i.LastRestockDate,
          i.NextRestockDate
        FROM 
          Inventory.StoreInventory i
        JOIN 
          Store.Store s ON i.StoreID = s.StoreID
        JOIN 
          Inventory.Product p ON i.ProductID = p.ProductID
        WHERE 
          p.IsActive = 1
        ORDER BY 
          s.StoreName, p.ProductName
        `

        const result = await executeSQL(query)
        return result.recordset
    } catch (error) {
        Logger.error('Error getting all inventory:', error.message);
        throw new Error(`Failed to get inventory: ${error.message}`);
    }
  },

  /**
   * Get inventory for a specific store
   * @param {number} storeId Store ID
   * @returns {Promise<Array>} Store inventory records
   */
  getStoreInventory: async (storeId) => {
    try {
        const query = `
        SELECT 
          i.InventoryID,
          i.StoreID,
          s.StoreName,
          i.ProductID,
          p.ProductName,
          p.SKU,
          p.RetailPrice,
          p.DiscountPrice,
          i.QuantityInStock,
          i.StockDate,
          i.LastRestockDate,
          i.NextRestockDate,
          p.MinStockLevel,
          p.ReorderPoint,
          CASE 
            WHEN i.QuantityInStock <= p.MinStockLevel THEN 'Low'
            WHEN i.QuantityInStock <= p.ReorderPoint THEN 'Medium'
            ELSE 'Good'
          END AS StockStatus
        FROM 
          Inventory.StoreInventory i
        JOIN 
          Store.Store s ON i.StoreID = s.StoreID
        JOIN 
          Inventory.Product p ON i.ProductID = p.ProductID
        WHERE 
          i.StoreID = @param0 AND p.IsActive = 1
        ORDER BY 
          p.ProductName
        `

        const result = await executeSQL(query, [storeId])
        return result.recordset
    } catch (error) {
        Logger.error(`Error getting store inventory for store ID ${storeId}:`, error.message);
        throw new Error(`Failed to get store inventory: ${error.message}`);
    }
  },

  /**
   * Get inventory for a specific product across all stores
   * @param {number} productId Product ID
   * @returns {Promise<Array>} Product inventory across stores
   */
  getProductInventory: async (productId) => {
    try {
        const query = `
          SELECT 
            i.InventoryID,
            i.StoreID,
            s.StoreName,
            s.StoreCode,
            i.ProductID,
            p.ProductName,
            p.SKU,
            i.QuantityInStock,
            i.StockDate,
            i.LastRestockDate,
            i.NextRestockDate
          FROM 
            Inventory.StoreInventory i
          JOIN 
            Store.Store s ON i.StoreID = s.StoreID
          JOIN 
            Inventory.Product p ON i.ProductID = p.ProductID
          WHERE 
            i.ProductID = @param0
          ORDER BY 
            s.StoreName
        `;
        
        const result = await executeSQL(query, [productId]);
        return result.recordset;
      } catch (error) {
        Logger.error(`Error getting product inventory for product ID ${productId}:`, error.message);
        throw new Error(`Failed to get product inventory: ${error.message}`);
      }
  },
  /**
   * Check availability of a product in a specific store
   * @param {number} storeId Store ID
   * @param {number} productId Product ID
   * @returns {Promise<Object>} Availability information
   */
  checkAvailability: async (storeId, productId) => {
    try {
      const query = `
        SELECT 
          i.QuantityInStock,
          s.StoreName,
          p.ProductName,
          p.SKU
        FROM 
          Inventory.StoreInventory i
        JOIN 
          Store.Store s ON i.StoreID = s.StoreID
        JOIN 
          Inventory.Product p ON i.ProductID = p.ProductID
        WHERE 
          i.StoreID = @param0 AND i.ProductID = @param1
      `;
      
      const result = await executeSQL(query, [storeId, productId]);
      
      if (result.recordset.length === 0) {
        return {
          available: false,
          message: 'Product not available in this store'
        };
      }
      
      return {
        available: result.recordset[0].QuantityInStock > 0,
        quantityInStock: result.recordset[0].QuantityInStock,
        product: {
          productId: productId,
          productName: result.recordset[0].ProductName,
          sku: result.recordset[0].SKU
        },
        store: {
          storeId: storeId,
          storeName: result.recordset[0].StoreName
        }
      };
    } catch (error) {
      Logger.error(`Error checking availability for product ID ${productId} in store ID ${storeId}:`, error.message);
      throw new Error(`Failed to check availability: ${error.message}`);
    }
  },

  /**
   * Update inventory quantity
   * @param {number} storeId Store ID
   * @param {number} productId Product ID
   * @param {number} quantity Quantity to add (positive) or remove (negative)
   * @returns {Promise<Object>} Update result
   */
  updateInventory: async (storeId, productId, quantity) => {
    try {
      // First check if there's enough inventory for removal operations
      if (quantity < 0) {
        const availability = await inventoryService.checkAvailability(storeId, productId);
        if (!availability.available || availability.quantityInStock < Math.abs(quantity)) {
          throw new Error(`Insufficient inventory. Available: ${availability.quantityInStock || 0}, Requested: ${Math.abs(quantity)}`);
        }
      }
      
      // Check if inventory record exists
      const checkQuery = `
        SELECT 
          InventoryID, QuantityInStock
        FROM 
          Inventory.StoreInventory
        WHERE 
          StoreID = @param0 AND ProductID = @param1
      `;
      
      const checkResult = await executeSQL(checkQuery, [storeId, productId]);
      
      let inventoryId, newQuantity;
      
      if (checkResult.recordset.length === 0) {
        // Insert new inventory record
        const insertQuery = `
          INSERT INTO Inventory.StoreInventory (
            StoreID, 
            ProductID, 
            QuantityInStock, 
            StockDate,
            LastRestockDate
          )
          OUTPUT INSERTED.InventoryID, INSERTED.QuantityInStock
          VALUES (
            @param0, @param1, @param2, GETDATE(), GETDATE()
          )
        `;
        
        const insertResult = await executeSQL(insertQuery, [storeId, productId, quantity]);
        inventoryId = insertResult.recordset[0].InventoryID;
        newQuantity = insertResult.recordset[0].QuantityInStock;
      } else {
        // Update existing inventory record
        const currentInventoryId = checkResult.recordset[0].InventoryID;
        const currentQuantity = checkResult.recordset[0].QuantityInStock;
        newQuantity = currentQuantity + quantity;
        
        const updateQuery = `
          UPDATE Inventory.StoreInventory
          SET 
            QuantityInStock = @param2,
            LastRestockDate = CASE WHEN @param3 > 0 THEN GETDATE() ELSE LastRestockDate END,
            ModifiedDate = GETDATE()
          WHERE 
            InventoryID = @param0
          
          SELECT @param0 AS InventoryID, @param2 AS QuantityInStock
        `;
        
        await executeSQL(updateQuery, [currentInventoryId, storeId, newQuantity, quantity]);
        inventoryId = currentInventoryId;
      }
      
      // Record the inventory transaction
      const transactionType = quantity > 0 ? 'Restock' : 'Removal';
      
      const transactionQuery = `
        INSERT INTO Inventory.InventoryTransaction (
          StoreID,
          ProductID,
          TransactionType,
          Quantity,
          TransactionDate,
          EmployeeID,
          Notes
        )
        VALUES (
          @param0, 
          @param1, 
          @param2, 
          @param3, 
          GETDATE(), 
          1, -- Default employee ID
          @param4
        )
      `;
      
      await executeSQL(transactionQuery, [
        storeId, 
        productId, 
        transactionType, 
        quantity, 
        `API: ${transactionType} operation`
      ]);
      
      return {
        inventoryId,
        quantityInStock: newQuantity,
        updated: checkResult.recordset.length > 0
      };
    } catch (error) {
      Logger.error(`Error updating inventory for product ID ${productId} in store ID ${storeId}:`, error.message);
      throw new Error(`Failed to update inventory: ${error.message}`);
    }
  },

  /**
   * Get products with low stock
   * @returns {Promise<Array>} Low stock products
   */
  getLowStockItems: async () => {
    try {
      const query = `
        SELECT 
          i.InventoryID,
          i.StoreID,
          s.StoreName,
          i.ProductID,
          p.ProductName,
          p.SKU,
          p.RetailPrice,
          i.QuantityInStock,
          p.MinStockLevel,
          p.ReorderPoint,
          p.MaxStockLevel,
          CASE 
            WHEN i.QuantityInStock <= p.MinStockLevel THEN 'Critical'
            WHEN i.QuantityInStock <= p.ReorderPoint THEN 'Low'
            ELSE 'OK'
          END AS StockStatus
        FROM 
          Inventory.StoreInventory i
        JOIN 
          Store.Store s ON i.StoreID = s.StoreID
        JOIN 
          Inventory.Product p ON i.ProductID = p.ProductID
        WHERE 
          i.QuantityInStock <= p.ReorderPoint AND p.IsActive = 1
        ORDER BY 
          StockStatus, s.StoreName, p.ProductName
      `;
      
      const result = await executeSQL(query);
      return result.recordset;
    } catch (error) {
      Logger.error('Error getting low stock items:', error.message);
      throw new Error(`Failed to get low stock items: ${error.message}`);
    }
  },

  /**
   * Get inventory transactions for a specific store
   * @param {number} storeId Store ID
   * @param {number} limit Maximum number of records to return
   * @returns {Promise<Array>} Transaction records
   */
  getInventoryTransactions: async (storeId, limit = 100) => {
    try {
      const query = `
        SELECT TOP ${limit}
          t.TransactionID,
          t.StoreID,
          s.StoreName,
          t.ProductID,
          p.ProductName,
          p.SKU,
          t.TransactionType,
          t.Quantity,
          t.TransactionDate,
          t.SourceStoreID,
          ss.StoreName as SourceStoreName,
          t.EmployeeID,
          e.FirstName + ' ' + e.LastName as EmployeeName,
          t.Notes
        FROM 
          Inventory.InventoryTransaction t
        JOIN 
          Store.Store s ON t.StoreID = s.StoreID
        JOIN 
          Inventory.Product p ON t.ProductID = p.ProductID
        JOIN 
          HR.Employee e ON t.EmployeeID = e.EmployeeID
        LEFT JOIN 
          Store.Store ss ON t.SourceStoreID = ss.StoreID
        WHERE 
          t.StoreID = @param0
        ORDER BY 
          t.TransactionDate DESC
      `;
      
      const result = await executeSQL(query, [storeId]);
      return result.recordset;
    } catch (error) {
      Logger.error(`Error getting inventory transactions for store ID ${storeId}:`, error.message);
      throw new Error(`Failed to get inventory transactions: ${error.message}`);
    }
  },

  /**
   * Transfer inventory between stores
   * @param {number} sourceStoreId Source store ID
   * @param {number} targetStoreId Target store ID
   * @param {number} productId Product ID
   * @param {number} quantity Quantity to transfer
   * @returns {Promise<Object>} Transfer result
   */
  transferInventory: async (sourceStoreId, targetStoreId, productId, quantity) => {
    try {
      if (sourceStoreId === targetStoreId) {
        throw new Error('Source and target stores must be different');
      }
      
      if (quantity <= 0) {
        throw new Error('Transfer quantity must be greater than zero');
      }
      
      // Check availability in source store
      const availability = await inventoryService.checkAvailability(sourceStoreId, productId);
      
      if (!availability.available || availability.quantityInStock < quantity) {
        throw new Error(`Insufficient inventory in source store. Available: ${availability.quantityInStock || 0}, Requested: ${quantity}`);
      }
      
      // Decrease source store inventory
      await inventoryService.updateInventory(sourceStoreId, productId, -quantity);
      
      // Increase target store inventory
      await inventoryService.updateInventory(targetStoreId, productId, quantity);
      
      // Record transfer transaction
      const transferQuery = `
        INSERT INTO Inventory.InventoryTransaction (
          StoreID,
          ProductID,
          TransactionType,
          Quantity,
          TransactionDate,
          SourceStoreID,
          EmployeeID,
          Notes
        )
        VALUES (
          @param0, 
          @param1, 
          'Transfer', 
          @param2, 
          GETDATE(),
          @param3,
          1,
          'API: Transfer between stores'
        )
      `;
      
      await executeSQL(transferQuery, [targetStoreId, productId, quantity, sourceStoreId]);
      
      return {
        success: true,
        message: `Successfully transferred ${quantity} units from store ${sourceStoreId} to store ${targetStoreId}`,
        sourceStoreId,
        targetStoreId,
        productId,
        quantity
      };
    } catch (error) {
      Logger.error(`Error transferring inventory from store ID ${sourceStoreId} to store ID ${targetStoreId}:`, error.message);
      throw new Error(`Failed to transfer inventory: ${error.message}`);
    }
  }
}

module.exports = inventoryService;