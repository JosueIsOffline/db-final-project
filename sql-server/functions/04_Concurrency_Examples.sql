/*
    Retail Chain Management System - Ejemplos de Concurrencia Simplificados
    Final Project - Advanced Database
    ITLA

    Este script demuestra problemas simples de concurrencia y sus soluciones:
    1. Problema del inventario (múltiples ventas simultaneas)
    2. Bloqueos y deadlocks
*/

USE RetailChainDB;
GO

-- =============================================
-- 1. Problema de inventario con múltiples ventas
-- =============================================

-- Crear tabla temporal para demostración
IF OBJECT_ID('tempdb..#InventoryDemo') IS NOT NULL
    DROP TABLE #InventoryDemo;

CREATE TABLE #InventoryDemo (
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(100),
    QuantityInStock INT
);

-- Insertar datos de prueba
INSERT INTO #InventoryDemo (ProductID, ProductName, QuantityInStock)
VALUES (1, 'Smartphone', 10);
GO

-- Procedimiento para simular venta (sin control adecuado)
CREATE OR ALTER PROCEDURE #SimulateUnsafeSale
    @ProductID INT,
    @Quantity INT,
    @WaitTime VARCHAR(8) = '00:00:01'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @AvailableStock INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verificar inventario disponible
        SELECT @AvailableStock = QuantityInStock
        FROM #InventoryDemo
        WHERE ProductID = @ProductID;
        
        PRINT 'Inventario disponible: ' + CAST(@AvailableStock AS VARCHAR);
        
        -- Simular tiempo de procesamiento
        WAITFOR DELAY @WaitTime;
        
        -- Verificar si hay suficiente stock
        IF @AvailableStock >= @Quantity
        BEGIN
            -- Actualizar inventario
            UPDATE #InventoryDemo
            SET QuantityInStock = QuantityInStock - @Quantity
            WHERE ProductID = @ProductID;
            
            PRINT 'Venta exitosa de ' + CAST(@Quantity AS VARCHAR) + ' unidades';
        END
        ELSE
        BEGIN
            PRINT 'Inventario insuficiente para la venta';
        END
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

-- Procedimiento para simular venta (con control adecuado usando UPDLOCK)
CREATE OR ALTER PROCEDURE #SimulateSafeSale
    @ProductID INT,
    @Quantity INT,
    @WaitTime VARCHAR(8) = '00:00:01'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @AvailableStock INT;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Verificar inventario disponible con bloqueo de actualización
        -- UPDLOCK bloquea la fila para actualizaciones hasta que termine la transacción
        SELECT @AvailableStock = QuantityInStock
        FROM #InventoryDemo WITH (UPDLOCK)
        WHERE ProductID = @ProductID;
        
        PRINT 'Inventario disponible: ' + CAST(@AvailableStock AS VARCHAR);
        
        -- Simular tiempo de procesamiento
        WAITFOR DELAY @WaitTime;
        
        -- Verificar si hay suficiente stock
        IF @AvailableStock >= @Quantity
        BEGIN
            -- Actualizar inventario
            UPDATE #InventoryDemo
            SET QuantityInStock = QuantityInStock - @Quantity
            WHERE ProductID = @ProductID;
            
            PRINT 'Venta exitosa de ' + CAST(@Quantity AS VARCHAR) + ' unidades';
        END
        ELSE
        BEGIN
            PRINT 'Inventario insuficiente para la venta';
        END
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

-- Instrucciones para la demostración
PRINT '=== DEMOSTRACIÓN DE PROBLEMA DE INVENTARIO ===';
PRINT 'Para demostrar el problema, ejecuta estos comandos en este orden:';
PRINT '';
PRINT '-- Primero, resetear el inventario:';
PRINT 'UPDATE #InventoryDemo SET QuantityInStock = 10 WHERE ProductID = 1;';
PRINT '';
PRINT '-- Luego, ejecutar las siguientes consultas en DOS ventanas distintas casi al mismo tiempo:';
PRINT '-- Ventana 1:';
PRINT 'EXEC #SimulateUnsafeSale 1, 6, ''00:00:02'';';
PRINT '';
PRINT '-- Ventana 2:';
PRINT 'EXEC #SimulateUnsafeSale 1, 7, ''00:00:02'';';
PRINT '';
PRINT 'Resultado probable: Ambas ventas serán exitosas, pero se venderán 13 unidades cuando solo hay 10 en stock!';
PRINT '';
PRINT '-- Ahora, la solución con UPDLOCK:';
PRINT 'UPDATE #InventoryDemo SET QuantityInStock = 10 WHERE ProductID = 1;';
PRINT '';
PRINT '-- Ejecutar estos comandos en DOS ventanas distintas casi al mismo tiempo:';
PRINT '-- Ventana 1:';
PRINT 'EXEC #SimulateSafeSale 1, 6, ''00:00:02'';';
PRINT '';
PRINT '-- Ventana 2:';
PRINT 'EXEC #SimulateSafeSale 1, 7, ''00:00:02'';';
PRINT '';
PRINT 'Resultado esperado: Solo una venta será exitosa, la otra reportará inventario insuficiente';
PRINT '';
GO

-- =============================================
-- 2. Ejemplo de deadlock simple
-- =============================================

-- Crear tablas para demostración
IF OBJECT_ID('tempdb..#Products') IS NOT NULL
    DROP TABLE #Products;

IF OBJECT_ID('tempdb..#Inventory') IS NOT NULL
    DROP TABLE #Inventory;

CREATE TABLE #Products (
    ProductID INT PRIMARY KEY,
    ProductName NVARCHAR(100),
    Price DECIMAL(10, 2)
);

CREATE TABLE #Inventory (
    InventoryID INT PRIMARY KEY,
    ProductID INT,
    QuantityInStock INT
);

-- Insertar datos de prueba
INSERT INTO #Products (ProductID, ProductName, Price)
VALUES (1, 'Laptop', 1200);

INSERT INTO #Inventory (InventoryID, ProductID, QuantityInStock)
VALUES (1, 1, 50);
GO

-- Procedimiento que causa deadlock (actualiza primero Productos, luego Inventario)
CREATE OR ALTER PROCEDURE #UpdateProductFirst
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Primer bloqueo: tabla Productos
        PRINT 'Actualizando tabla Products...';
        UPDATE #Products
        SET Price = Price * 1.10
        WHERE ProductID = 1;
        
        -- Esperar para simular procesamiento
        WAITFOR DELAY '00:00:03';
        
        -- Segundo bloqueo: tabla Inventario
        PRINT 'Actualizando tabla Inventory...';
        UPDATE #Inventory
        SET QuantityInStock = QuantityInStock - 5
        WHERE ProductID = 1;
        
        COMMIT TRANSACTION;
        PRINT 'Transacción completada con éxito';
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 1205 -- Código de deadlock
        BEGIN
            PRINT '¡Deadlock detectado! Esta transacción fue elegida como víctima';
            
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END
        ELSE
        BEGIN
            PRINT 'Error: ' + ERROR_MESSAGE();
            
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END
    END CATCH;
END;
GO

-- Procedimiento que causa deadlock (actualiza primero Inventario, luego Productos)
CREATE OR ALTER PROCEDURE #UpdateInventoryFirst
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Primer bloqueo: tabla Inventario
        PRINT 'Actualizando tabla Inventory...';
        UPDATE #Inventory
        SET QuantityInStock = QuantityInStock - 10
        WHERE ProductID = 1;
        
        -- Esperar para simular procesamiento
        WAITFOR DELAY '00:00:03';
        
        -- Segundo bloqueo: tabla Productos
        PRINT 'Actualizando tabla Products...';
        UPDATE #Products
        SET Price = Price * 1.05
        WHERE ProductID = 1;
        
        COMMIT TRANSACTION;
        PRINT 'Transacción completada con éxito';
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 1205 -- Código de deadlock
        BEGIN
            PRINT '¡Deadlock detectado! Esta transacción fue elegida como víctima';
            
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END
        ELSE
        BEGIN
            PRINT 'Error: ' + ERROR_MESSAGE();
            
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
        END
    END CATCH;
END;
GO

-- Procedimiento que evita deadlock (siempre actualiza tablas en el mismo orden)
CREATE OR ALTER PROCEDURE #UpdateConsistentOrder
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Siempre actualizar tablas en el mismo orden: Productos primero, luego Inventario
        PRINT 'Actualizando tabla Products...';
        UPDATE #Products
        SET Price = Price * 1.02
        WHERE ProductID = 1;
        
        PRINT 'Actualizando tabla Inventory...';
        UPDATE #Inventory
        SET QuantityInStock = QuantityInStock - 2
        WHERE ProductID = 1;
        
        COMMIT TRANSACTION;
        PRINT 'Transacción completada con éxito (sin deadlock)';
    END TRY
    BEGIN CATCH
        PRINT 'Error: ' + ERROR_MESSAGE();
        
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
    END CATCH;
END;
GO

-- Instrucciones para la demostración de deadlock
PRINT '=== DEMOSTRACIÓN DE DEADLOCK ===';
PRINT 'Para provocar un deadlock, ejecuta estos comandos en este orden:';
PRINT '';
PRINT '-- Primero, resetear datos si es necesario:';
PRINT 'UPDATE #Products SET Price = 1200 WHERE ProductID = 1;';
PRINT 'UPDATE #Inventory SET QuantityInStock = 50 WHERE InventoryID = 1;';
PRINT '';
PRINT '-- Luego, ejecutar estos procedimientos en DOS ventanas distintas casi al mismo tiempo:';
PRINT '-- Ventana 1:';
PRINT 'EXEC #UpdateProductFirst;';
PRINT '';
PRINT '-- Ventana 2:';
PRINT 'EXEC #UpdateInventoryFirst;';
PRINT '';
PRINT 'Resultado esperado: Se producirá un deadlock y SQL Server elegirá una de las transacciones como víctima';
PRINT '';
PRINT '-- Solución al deadlock - Usar orden consistente:';
PRINT 'UPDATE #Products SET Price = 1200 WHERE ProductID = 1;';
PRINT 'UPDATE #Inventory SET QuantityInStock = 50 WHERE InventoryID = 1;';
PRINT '';
PRINT '-- Ejecutar estos procedimientos en DOS ventanas distintas casi al mismo tiempo:';
PRINT '-- Ambas ventanas:';
PRINT 'EXEC #UpdateConsistentOrder;';
PRINT '';
PRINT 'Resultado esperado: Ambas transacciones se ejecutarán sin deadlock';
PRINT '';
GO

-- Instrucciones de limpieza (opcional)
PRINT '=== LIMPIEZA DE OBJETOS TEMPORALES ===';
PRINT 'Para limpiar los objetos temporales creados, ejecuta:';
PRINT '';
PRINT 'DROP PROCEDURE #SimulateUnsafeSale;';
PRINT 'DROP PROCEDURE #SimulateSafeSale;';
PRINT 'DROP PROCEDURE #UpdateProductFirst;';
PRINT 'DROP PROCEDURE #UpdateInventoryFirst;';
PRINT 'DROP PROCEDURE #UpdateConsistentOrder;';
PRINT 'DROP TABLE #InventoryDemo;';
PRINT 'DROP TABLE #Inventory;';
PRINT 'DROP TABLE #Products;';
GO