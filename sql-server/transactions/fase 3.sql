USE RetailChainDB;  -- Replace with your actual database name!
GO

-- Fase 3: Gestión de Transacciones
-- -----------------------------------------

-- 1. Transacción para registrar una venta y actualizar el inventario
BEGIN TRANSACTION;

BEGIN TRY
    -- Registrar la venta
    INSERT INTO Sales.Sale (SaleNumber, StoreID, EmployeeID, SaleDate, SubTotal, TaxAmount, TotalAmount, PaymentMethodID)  
    VALUES (NEWID(), 1, 101, GETDATE(), 100.00, 16.00, 116.00, 1);  -- Example data

    -- Actualizar el inventario del producto
    UPDATE Inventory.StoreInventory
    SET QuantityInStock = QuantityInStock - 1
    WHERE ProductID = 201 AND StoreID = 1;  -- Example ProductID and StoreID

    -- Confirmar la transacción
    COMMIT TRANSACTION;
    SELECT 'Transaction committed successfully.' AS Result;
END TRY
BEGIN CATCH
    -- Si hay error, hacer rollback
    ROLLBACK TRANSACTION;
    SELECT 'Transaction rolled back due to error.' AS Result, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

GO  -- Batch separator

-- 2. Transacción con diferentes niveles de aislamiento (para controlar la concurrencia)
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;  -- Change isolation level as needed

BEGIN TRANSACTION;

BEGIN TRY
    -- Operaciones dentro de la transacción
    UPDATE Inventory.StoreInventory
    SET QuantityInStock = QuantityInStock - 2
    WHERE ProductID = 202 AND StoreID = 2;  -- Example ProductID and StoreID

    COMMIT TRANSACTION;
    SELECT 'Transaction committed successfully.' AS Result;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    SELECT 'Transaction rolled back due to error.' AS Result, ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED; -- Restore to default or desired level
GO

-- 3. Ejemplo de cómo manejar concurrencia usando BEGIN TRAN y transacciones de actualización simultáneas
BEGIN TRANSACTION;

-- Actualizar el precio de un producto
UPDATE Inventory.Product
SET RetailPrice = 200.00
WHERE ProductID = 203;  -- Example ProductID

WAITFOR DELAY '00:00:10';  -- Simulate a delay (e.g., other transaction)

-- Verificar el cambio within the transaction
SELECT RetailPrice FROM Inventory.Product WHERE ProductID = 203;

COMMIT TRANSACTION;
SELECT 'Transaction committed successfully.' AS Result;

-- Verify the change after the transaction
SELECT RetailPrice FROM Inventory.Product WHERE ProductID = 203;
GO

COMMIT