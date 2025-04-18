const { executeSQL } = require('../databases/sqlClient');

// Modelo para productos en SQL Server
class Product {
  // Obtener todos los productos
  static async getAllProducts(limit = 100) {
    const query = `
      SELECT TOP ${limit}
        p.ProductID, 
        p.ProductName, 
        p.SKU, 
        p.Description,
        c.CategoryName,
        p.RetailPrice,
        p.DiscountPrice
      FROM 
        Inventory.Product p
      JOIN 
        Inventory.Category c ON p.CategoryID = c.CategoryID
      WHERE 
        p.IsActive = 1
      ORDER BY 
        p.ProductName
    `;
    
    const result = await executeSQL(query);
    return result.recordset;
  }

  // Obtener producto por ID
  static async getProductById(productId) {
    const query = `
      SELECT 
        p.ProductID, 
        p.ProductName, 
        p.SKU, 
        p.Description,
        c.CategoryName,
        p.RetailPrice,
        p.DiscountPrice,
        p.Weight,
        p.Dimensions
      FROM 
        Inventory.Product p
      JOIN 
        Inventory.Category c ON p.CategoryID = c.CategoryID
      WHERE 
        p.ProductID = @param0 AND p.IsActive = 1
    `;
    
    const result = await executeSQL(query, [productId]);
    return result.recordset[0];
  }

  // Buscar productos por nombre o categoría
  static async searchProducts(searchTerm) {
    const query = `
      SELECT 
        p.ProductID, 
        p.ProductName, 
        p.SKU, 
        c.CategoryName,
        p.RetailPrice,
        p.DiscountPrice
      FROM 
        Inventory.Product p
      JOIN 
        Inventory.Category c ON p.CategoryID = c.CategoryID
      WHERE 
        (p.ProductName LIKE '%' + @param0 + '%' OR
        c.CategoryName LIKE '%' + @param0 + '%') AND
        p.IsActive = 1
      ORDER BY 
        p.ProductName
    `;
    
    const result = await executeSQL(query, [searchTerm]);
    return result.recordset;
  }
}

// Modelo para inventario en SQL Server
class Inventory {
  // Verificar disponibilidad de un producto en una tienda
  static async checkAvailability(storeId, productId) {
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
        message: 'Producto no disponible en esta tienda'
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
  }
  
  // Actualizar inventario (reserva o liberación)
  static async updateInventory(storeId, productId, quantity) {
    // Primero verificamos si hay suficiente inventario
    if (quantity < 0) {
      const availability = await this.checkAvailability(storeId, productId);
      if (!availability.available || availability.quantityInStock < Math.abs(quantity)) {
        throw new Error('Inventario insuficiente para esta operación');
      }
    }
    
    const query = `
      UPDATE Inventory.StoreInventory
      SET 
        QuantityInStock = QuantityInStock + @param2,
        ModifiedDate = GETDATE()
      WHERE 
        StoreID = @param0 AND ProductID = @param1;
      
      -- Retornar el nuevo valor
      SELECT QuantityInStock
      FROM Inventory.StoreInventory
      WHERE StoreID = @param0 AND ProductID = @param1;
    `;
    
    const result = await executeSQL(query, [storeId, productId, quantity]);
    
    // Añadir transacción en la tabla de transacciones
    const transactionType = quantity < 0 ? 'Sale' : 'Return';
    
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
        1, -- ID de empleado por defecto
        @param4
      )
    `;
    
    await executeSQL(transactionQuery, [
      storeId, 
      productId, 
      transactionType, 
      quantity, 
      `API: ${transactionType} de producto`
    ]);
    
    return {
      updated: true,
      newQuantity: result.recordset[0]?.QuantityInStock || 0
    };
  }
  
  // Obtener inventario para una tienda
  static async getStoreInventory(storeId) {
    const query = `
      SELECT 
        i.StoreID,
        s.StoreName,
        i.ProductID,
        p.ProductName,
        p.SKU,
        i.QuantityInStock
      FROM 
        Inventory.StoreInventory i
      JOIN 
        Store.Store s ON i.StoreID = s.StoreID
      JOIN 
        Inventory.Product p ON i.ProductID = p.ProductID
      WHERE 
        i.StoreID = @param0 AND i.QuantityInStock > 0
      ORDER BY 
        p.ProductName
    `;
    
    const result = await executeSQL(query, [storeId]);
    return result.recordset;
  }
}

// Modelo para tiendas en SQL Server
class Store {
  // Obtener todas las tiendas
  static async getAllStores() {
    const query = `
      SELECT 
        s.StoreID, 
        s.StoreName, 
        s.StoreCode,
        t.TypeName as StoreType,
        s.Address,
        c.CityName,
        r.RegionName,
        co.CountryName,
        s.Phone,
        s.Email,
        s.OpeningDate
      FROM 
        Store.Store s
      JOIN 
        Store.StoreType t ON s.StoreTypeID = t.StoreTypeID
      JOIN 
        Store.City c ON s.CityID = c.CityID
      JOIN 
        Store.Region r ON c.RegionID = r.RegionID
      JOIN 
        Store.Country co ON r.CountryID = co.CountryID
      WHERE 
        s.IsActive = 1
      ORDER BY 
        s.StoreName
    `;
    
    const result = await executeSQL(query);
    return result.recordset;
  }
  
  // Obtener tienda por ID
  static async getStoreById(storeId) {
    const query = `
      SELECT 
        s.StoreID, 
        s.StoreName, 
        s.StoreCode,
        t.TypeName as StoreType,
        s.Address,
        c.CityName,
        r.RegionName,
        co.CountryName,
        s.Phone,
        s.Email
      FROM 
        Store.Store s
      JOIN 
        Store.StoreType t ON s.StoreTypeID = t.StoreTypeID
      JOIN 
        Store.City c ON s.CityID = c.CityID
      JOIN 
        Store.Region r ON c.RegionID = r.RegionID
      JOIN 
        Store.Country co ON r.CountryID = co.CountryID
      WHERE 
        s.StoreID = @param0 AND s.IsActive = 1
    `;
    
    const result = await executeSQL(query, [storeId]);
    return result.recordset[0];
  }
}

module.exports = {
  Product,
  Inventory,
  Store
};