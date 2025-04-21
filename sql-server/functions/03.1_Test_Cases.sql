USE RetailChainDB;
GO

-- Antes de las pruebas, verificar los datos existentes
PRINT '===== DATOS ACTUALES ANTES DE PRUEBAS =====';

-- Ver productos disponibles
PRINT 'Productos disponibles:';
SELECT TOP 5 ProductID, ProductName, RetailPrice FROM Inventory.Product;

-- Ver tiendas disponibles
PRINT 'Tiendas disponibles:';
SELECT TOP 5 StoreID, StoreName, StoreCode FROM Store.Store;

-- Ver inventario actual
PRINT 'Inventario actual:';
SELECT TOP 10 StoreID, ProductID, QuantityInStock 
FROM Inventory.StoreInventory
ORDER BY StoreID, ProductID;

-- Ver empleados
PRINT 'Empleados disponibles:';
SELECT TOP 5 EmployeeID, FirstName, LastName FROM HR.Employee;

-- Ver clientes
PRINT 'Clientes disponibles:';
SELECT TOP 5 CustomerID, FirstName, LastName FROM Sales.Customer;

-- Después de verificar, elegir IDs específicos para las pruebas
DECLARE @TestStoreID INT = 1;           -- Usar una tienda existente
DECLARE @TestProductID INT = 1;         -- Usar un producto existente
DECLARE @TestCustomerID INT = 1;        -- Usar un cliente existente
DECLARE @TestEmployeeID INT = 1;        -- Usar un empleado existente
DECLARE @TestTargetStoreID INT = 2;     -- Tienda destino para transferencia

-- 1. Probar RegisterSale (caso exitoso)
PRINT '===== PROBANDO REGISTRO DE VENTA (CASO EXITOSO) =====';

-- Verificar inventario antes de la venta
PRINT 'Inventario antes de la venta:';
SELECT * FROM Inventory.StoreInventory 
WHERE StoreID = @TestStoreID AND ProductID = @TestProductID;

-- Cantidad a vender (asegúrate de usar un número menor al inventario disponible)
DECLARE @QuantityToSell INT = 1;  -- Ajusta esto según el inventario disponible
DECLARE @SaleID INT;

EXEC Sales.RegisterSale
    @StoreID = @TestStoreID,
    @ProductID = @TestProductID,
    @Quantity = @QuantityToSell,
    @CustomerID = @TestCustomerID,
    @EmployeeID = @TestEmployeeID,
    @SaleID = @SaleID OUTPUT;

-- Verificar los resultados
PRINT 'Venta registrada con ID: ' + CAST(ISNULL(@SaleID, 0) AS VARCHAR);

PRINT 'Detalles de la venta:';
SELECT * FROM Sales.Sale WHERE SaleID = @SaleID;
SELECT * FROM Sales.SaleDetail WHERE SaleID = @SaleID;

PRINT 'Inventario después de la venta:';
SELECT * FROM Inventory.StoreInventory 
WHERE StoreID = @TestStoreID AND ProductID = @TestProductID;

PRINT 'Transacción de inventario:';
SELECT * FROM Inventory.InventoryTransaction
WHERE SaleID = @SaleID;

-- 2. Probar RegisterSale (caso fallido - inventario insuficiente)
PRINT '===== PROBANDO REGISTRO DE VENTA (CASO FALLIDO) =====';

-- Obtener la cantidad actual en inventario
DECLARE @CurrentStock INT;
SELECT @CurrentStock = QuantityInStock 
FROM Inventory.StoreInventory
WHERE StoreID = @TestStoreID AND ProductID = @TestProductID;

-- Intentar vender más de lo que hay
DECLARE @ExcessiveQuantity INT = @CurrentStock + 10;  -- 10 más que el inventario disponible
DECLARE @SaleID2 INT;

BEGIN TRY
    EXEC Sales.RegisterSale
        @StoreID = @TestStoreID,
        @ProductID = @TestProductID,
        @Quantity = @ExcessiveQuantity,
        @CustomerID = @TestCustomerID,
        @EmployeeID = @TestEmployeeID,
        @SaleID = @SaleID2 OUTPUT;
END TRY
BEGIN CATCH
    PRINT 'Error esperado: ' + ERROR_MESSAGE();
END CATCH

-- 3. Probar TransferStock
PRINT '===== PROBANDO TRANSFERENCIA DE INVENTARIO =====';

-- Seleccionar un producto que exista en ambas tiendas o solo en la origen
DECLARE @TransferProductID INT = @TestProductID;  -- Usa un producto que sepas que existe en la tienda origen

-- Verificar inventario antes de transferencia
PRINT 'Inventario antes de transferencia:';
SELECT 'Tienda Origen' AS Tienda, * FROM Inventory.StoreInventory 
WHERE StoreID = @TestStoreID AND ProductID = @TransferProductID;
SELECT 'Tienda Destino' AS Tienda, * FROM Inventory.StoreInventory 
WHERE StoreID = @TestTargetStoreID AND ProductID = @TransferProductID;

-- Obtener cantidad actual para transferir menos de lo disponible
DECLARE @TransferQuantity INT;
SELECT @TransferQuantity = QuantityInStock / 2  -- Transferir la mitad del inventario
FROM Inventory.StoreInventory
WHERE StoreID = @TestStoreID AND ProductID = @TransferProductID;

-- Asegurar que transfiera al menos 1 unidad
SET @TransferQuantity = CASE WHEN @TransferQuantity < 1 THEN 1 ELSE @TransferQuantity END;

-- Ejecutar transferencia
EXEC Inventory.TransferStock
    @SourceStoreID = @TestStoreID,
    @TargetStoreID = @TestTargetStoreID,
    @ProductID = @TransferProductID,
    @Quantity = @TransferQuantity,
    @EmployeeID = @TestEmployeeID;

-- Verificar inventario después de transferencia
PRINT 'Inventario después de transferencia:';
SELECT 'Tienda Origen' AS Tienda, * FROM Inventory.StoreInventory 
WHERE StoreID = @TestStoreID AND ProductID = @TransferProductID;
SELECT 'Tienda Destino' AS Tienda, * FROM Inventory.StoreInventory 
WHERE StoreID = @TestTargetStoreID AND ProductID = @TransferProductID;

PRINT 'Transacciones de inventario:';
SELECT TOP 2 * FROM Inventory.InventoryTransaction
WHERE ProductID = @TransferProductID 
ORDER BY TransactionID DESC;

-- 4. Probar TransferStock (caso fallido - inventario insuficiente)
PRINT '===== PROBANDO TRANSFERENCIA DE INVENTARIO (CASO FALLIDO) =====';

-- Obtener cantidad actual
DECLARE @CurrentTransferStock INT;
SELECT @CurrentTransferStock = QuantityInStock 
FROM Inventory.StoreInventory
WHERE StoreID = @TestStoreID AND ProductID = @TransferProductID;

-- Intentar transferir más de lo disponible
DECLARE @ExcessiveTransfer INT = @CurrentTransferStock + 10;

BEGIN TRY
    EXEC Inventory.TransferStock
        @SourceStoreID = @TestStoreID,
        @TargetStoreID = @TestTargetStoreID,
        @ProductID = @TransferProductID,
        @Quantity = @ExcessiveTransfer,
        @EmployeeID = @TestEmployeeID;
END TRY
BEGIN CATCH
    PRINT 'Error esperado: ' + ERROR_MESSAGE();
END CATCH

PRINT '===== PRUEBAS COMPLETADAS =====';