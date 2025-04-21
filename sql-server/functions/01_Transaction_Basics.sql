/*
    Retail Chain Management System - Transaction Basics
    Final Project - Advanced Database
    ITLA

    Este script demuestra los conceptos básicos de transacciones en SQL Server:
    - BEGIN TRANSACTION
    - COMMIT TRANSACTION
    - ROLLBACK TRANSACTION
    - Manejo de errores con TRY-CATCH

    Las transacciones garantizan que un conjunto de operaciones se ejecuten como una unidad atómica,
    cumpliendo con las propiedades ACID (Atomicidad, Consistencia, Aislamiento y Durabilidad).
*/

USE RetailChainDB;
GO

PRINT '=== EJEMPLO 1: Transacción básica con COMMIT ===';
-- Una transacción simple que actualiza el precio de un producto

BEGIN TRY
    BEGIN TRANSACTION;
        
        PRINT 'Actualizando precio de producto...';
        
        -- Guardamos el precio original para mostrarlo
        DECLARE @oldPrice DECIMAL(10, 2);
        DECLARE @productID INT = 1; -- Asumimos que existe este producto
        
        SELECT @oldPrice = RetailPrice 
        FROM Inventory.Product 
        WHERE ProductID = @productID;
        
        -- Actualizamos el precio
        UPDATE Inventory.Product 
        SET RetailPrice = RetailPrice * 1.10 -- Aumento del 10%
        WHERE ProductID = @productID;
        
        -- Registramos el cambio en la tabla de auditoría
        INSERT INTO Audit.PriceHistory (
            ProductID, 
            OldRetailPrice, 
            NewRetailPrice, 
            ChangedBy, 
            ChangeReason
        )
        VALUES (
            @productID, 
            @oldPrice, 
            @oldPrice * 1.10,
            1, -- ID del empleado que realiza el cambio
            'Ajuste de precio por inflación'
        );
        
        PRINT 'Todas las operaciones completadas correctamente';
        
    COMMIT TRANSACTION;
    PRINT 'Transacción confirmada (COMMIT)';
END TRY
BEGIN CATCH
    -- Si ocurre un error, revertimos todos los cambios
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
        
    PRINT 'Error detectado. Transacción revertida (ROLLBACK)';
    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH;

GO

PRINT '=== EJEMPLO 2: Transacción con ROLLBACK intencional ===';
-- Demostración de rollback manual por condición de negocio

BEGIN TRY
    BEGIN TRANSACTION;
        
        PRINT 'Intentando registro de venta con inventario insuficiente...';
        
        DECLARE @productID INT = 2; -- Asumimos que existe este producto
        DECLARE @storeID INT = 1;   -- Asumimos que existe esta tienda
        DECLARE @quantityRequested INT = 100;
        DECLARE @quantityInStock INT;
        
        -- Verificamos el inventario disponible
        SELECT @quantityInStock = QuantityInStock 
        FROM Inventory.StoreInventory 
        WHERE ProductID = @productID AND StoreID = @storeID;
        
        -- Validamos si hay suficiente inventario
        IF @quantityInStock < @quantityRequested
        BEGIN
            PRINT 'Inventario insuficiente. Disponible: ' + 
                  CAST(@quantityInStock AS VARCHAR) + ', Solicitado: ' + 
                  CAST(@quantityRequested AS VARCHAR);
            
            -- Rollback explícito por regla de negocio
            ROLLBACK TRANSACTION;
            PRINT 'Transacción revertida (ROLLBACK) por inventario insuficiente';
            RETURN;
        END
        
        -- Si llegamos aquí, hay suficiente inventario
        PRINT 'Inventario suficiente. Procesando venta...';
        
        -- Actualización del inventario
        UPDATE Inventory.StoreInventory
        SET QuantityInStock = QuantityInStock - @quantityRequested
        WHERE ProductID = @productID AND StoreID = @storeID;
        
        -- Aquí continuaría con la creación de la venta, detalles, etc.
        
    COMMIT TRANSACTION;
    PRINT 'Transacción confirmada (COMMIT)';
END TRY
BEGIN CATCH
    -- Si ocurre un error técnico, revertimos todos los cambios
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
        
    PRINT 'Error detectado. Transacción revertida (ROLLBACK)';
    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH;

GO

PRINT '=== EJEMPLO 3: Transacción con puntos de guardado (SAVEPOINT) ===';
-- Uso de puntos de guardado para control granular de la transacción

BEGIN TRY
    BEGIN TRANSACTION;
    
    PRINT 'Iniciando proceso de transferencia de inventario entre tiendas...';
    
    DECLARE @sourceStoreID INT = 1;
    DECLARE @targetStoreID INT = 2;
    DECLARE @productID INT = 3;
    DECLARE @transferQuantity INT = 20;
    
    -- Primer punto de guardado - después de validaciones iniciales
    SAVE TRANSACTION CheckpointValidation;
    
    -- Reducir inventario en tienda origen
    UPDATE Inventory.StoreInventory
    SET QuantityInStock = QuantityInStock - @transferQuantity
    WHERE StoreID = @sourceStoreID AND ProductID = @productID;
    
    -- Segundo punto de guardado - después de actualizar origen
    SAVE TRANSACTION CheckpointSourceUpdated;
    
    -- Verificar si el producto ya existe en tienda destino
    IF EXISTS (SELECT 1 FROM Inventory.StoreInventory 
               WHERE StoreID = @targetStoreID AND ProductID = @productID)
    BEGIN
        -- Actualizar inventario existente
        UPDATE Inventory.StoreInventory
        SET QuantityInStock = QuantityInStock + @transferQuantity
        WHERE StoreID = @targetStoreID AND ProductID = @productID;
    END
    ELSE
    BEGIN
        -- Crear nuevo registro de inventario
        INSERT INTO Inventory.StoreInventory (
            StoreID, ProductID, QuantityInStock
        )
        VALUES (
            @targetStoreID, @productID, @transferQuantity
        );
    END
    
    -- Registrar la transacción de inventario
    INSERT INTO Inventory.InventoryTransaction (
        StoreID, ProductID, TransactionType, Quantity, 
        SourceStoreID, EmployeeID, Notes
    )
    VALUES (
        @targetStoreID, @productID, 'Transfer', @transferQuantity,
        @sourceStoreID, 1, 'Transferencia de inventario entre tiendas'
    );
    
    COMMIT TRANSACTION;
    PRINT 'Transferencia de inventario completada exitosamente';
    
END TRY
BEGIN CATCH
    DECLARE @errorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @errorSeverity INT = ERROR_SEVERITY();
    
    -- Decisión sobre qué punto de recuperación usar
    IF @errorMessage LIKE '%target store%'
    BEGIN
        -- Si el error fue al actualizar la tienda destino, 
        -- volvemos al punto después de actualizar el origen
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION CheckpointSourceUpdated;
            PRINT 'Rollback parcial al punto CheckpointSourceUpdated';
            -- Aquí podríamos intentar una lógica alternativa
            COMMIT TRANSACTION;
        END
    END
    ELSE
    BEGIN
        -- Para cualquier otro error, revertimos todo
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        PRINT 'Error detectado. Transacción completamente revertida';
    END
    
    PRINT 'Error: ' + @errorMessage;
    
    -- Re-lanzar el error para que capas superiores lo manejen
    RAISERROR(@errorMessage, @errorSeverity, 1);
END CATCH;

GO