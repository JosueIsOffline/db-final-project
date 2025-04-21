/*
    Retail Chain Management System - Transacciones de Negocio Simplificadas
    Final Project - Advanced Database
    ITLA

    Este script implementa ejemplos básicos de transacciones para operaciones críticas del negocio:
    1. Proceso de venta con validación de inventario
    2. Transferencia de inventario entre tiendas
*/

USE RetailChainDB;
GO

-- =============================================
-- 1. Procedimiento para registrar una venta con transacción
-- =============================================
CREATE OR ALTER PROCEDURE Sales.RegisterSale
    @StoreID INT,
    @ProductID INT,
    @Quantity INT,
    @CustomerID INT = NULL,
    @EmployeeID INT,
    @SaleID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Variables para cálculos
    DECLARE @UnitPrice DECIMAL(10, 2);
    DECLARE @UnitCost DECIMAL(10, 2);
    DECLARE @TaxRate DECIMAL(5, 2) = 0.18; -- 18% de impuesto
    DECLARE @TaxAmount DECIMAL(10, 2);
    DECLARE @SubTotal DECIMAL(10, 2);
    DECLARE @TotalAmount DECIMAL(10, 2);
    DECLARE @SaleNumber NVARCHAR(50);
    DECLARE @QuantityInStock INT;
    DECLARE @AvailableQuantity INT;
    
    -- Obtener precio e inventario del producto
    SELECT 
        @UnitPrice = p.RetailPrice,
        @UnitCost = p.CostPrice
    FROM Inventory.Product p
    WHERE p.ProductID = @ProductID;
    
    -- Verificar que el producto existe
    IF @UnitPrice IS NULL
    BEGIN
        RAISERROR('El producto no existe', 16, 1);
        RETURN;
    END
    
    -- Verificar inventario disponible
    SELECT @QuantityInStock = QuantityInStock
    FROM Inventory.StoreInventory
    WHERE ProductID = @ProductID AND StoreID = @StoreID;
    
    -- Si no hay inventario, asigna 0 para mostrar en mensaje de error
    SET @AvailableQuantity = ISNULL(@QuantityInStock, 0);
    
    -- Iniciar la transacción
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar inventario suficiente
        IF @QuantityInStock IS NULL OR @QuantityInStock < @Quantity
        BEGIN
            -- No hay suficiente inventario
            ROLLBACK TRANSACTION;
            -- Usamos variables para el mensaje de error, no funciones directamente
            RAISERROR('No hay suficiente inventario. Disponible: %d, Solicitado: %d', 
                     16, 1, @AvailableQuantity, @Quantity);
            RETURN;
        END
        
        -- Calcular montos
        SET @SubTotal = @Quantity * @UnitPrice;
        SET @TaxAmount = @SubTotal * @TaxRate;
        SET @TotalAmount = @SubTotal + @TaxAmount;
        
        -- Generar número de venta único - CORREGIDO
        SET @SaleNumber = 'S-' + CAST(@StoreID AS VARCHAR) + '-' + 
                        CAST(YEAR(GETDATE()) AS VARCHAR) + 
                        RIGHT('0' + CAST(MONTH(GETDATE()) AS VARCHAR), 2) + 
                        RIGHT('0' + CAST(DAY(GETDATE()) AS VARCHAR), 2) + '-' + 
                        CAST(CAST(NEWID() AS VARBINARY(4)) AS VARCHAR(8)); -- Modificación aquí
        
        -- Insertar encabezado de venta
        INSERT INTO Sales.Sale (
            SaleNumber, StoreID, CustomerID, EmployeeID, SaleDate,
            SubTotal, TaxAmount, DiscountAmount, TotalAmount,
            PaymentMethodID, Status
        )
        VALUES (
            @SaleNumber, @StoreID, @CustomerID, @EmployeeID, GETDATE(),
            @SubTotal, @TaxAmount, 0, @TotalAmount,
            1, -- Método de pago por defecto (Efectivo)
            'Completed'
        );
        
        -- Obtener ID de la venta generada
        SET @SaleID = SCOPE_IDENTITY();
        
        -- Insertar detalle de venta
        INSERT INTO Sales.SaleDetail (
            SaleID, ProductID, Quantity, UnitPrice, UnitCost,
            Discount, TaxRate, TaxAmount, LineTotal
        )
        VALUES (
            @SaleID, @ProductID, @Quantity, @UnitPrice, @UnitCost,
            0, @TaxRate, @TaxAmount, @SubTotal
        );
        
        -- Actualizar inventario (reducir stock)
        UPDATE Inventory.StoreInventory
        SET QuantityInStock = QuantityInStock - @Quantity
        WHERE StoreID = @StoreID AND ProductID = @ProductID;
        
        -- Registrar transacción de inventario
        INSERT INTO Inventory.InventoryTransaction (
            StoreID, ProductID, TransactionType, Quantity,
            EmployeeID, SaleID, Notes
        )
        VALUES (
            @StoreID, @ProductID, 'Sale', -@Quantity,
            @EmployeeID, @SaleID, 'Venta: ' + @SaleNumber
        );
        
        -- Actualizar puntos de lealtad del cliente si aplica
        IF @CustomerID IS NOT NULL
        BEGIN
            -- Calcular puntos (1 punto por cada $10)
            DECLARE @PointsEarned INT = FLOOR(@TotalAmount / 10);
            
            UPDATE Sales.Customer
            SET LoyaltyPoints = LoyaltyPoints + @PointsEarned,
                LastPurchaseDate = GETDATE()
            WHERE CustomerID = @CustomerID;
            
            -- Actualizar puntos en la venta
            UPDATE Sales.Sale
            SET LoyaltyPointsEarned = @PointsEarned
            WHERE SaleID = @SaleID;
        END
        
        COMMIT TRANSACTION;
        
        PRINT 'Venta registrada con éxito. ID: ' + CAST(@SaleID AS VARCHAR) + 
              ', Número: ' + @SaleNumber;
    END TRY
    BEGIN CATCH
        -- Si hay error, revertir todos los cambios
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        PRINT 'Error al registrar la venta: ' + ERROR_MESSAGE();
        
        -- Re-lanzar el error para que la aplicación pueda manejarlo
        THROW;
    END CATCH;
END;
GO

-- =============================================
-- 2. Procedimiento para transferencia de inventario entre tiendas
-- =============================================
CREATE OR ALTER PROCEDURE Inventory.TransferStock
    @SourceStoreID INT,
    @TargetStoreID INT,
    @ProductID INT,
    @Quantity INT,
    @EmployeeID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Variables para validación
    DECLARE @SourceQuantity INT;
    
    -- Validar datos básicos
    IF @SourceStoreID = @TargetStoreID
    BEGIN
        RAISERROR('Las tiendas origen y destino no pueden ser iguales', 16, 1);
        RETURN;
    END
    
    IF @Quantity <= 0
    BEGIN
        RAISERROR('La cantidad a transferir debe ser mayor que cero', 16, 1);
        RETURN;
    END
    
    -- Verificar inventario en tienda origen
    SELECT @SourceQuantity = QuantityInStock
    FROM Inventory.StoreInventory
    WHERE StoreID = @SourceStoreID AND ProductID = @ProductID;
    
    IF @SourceQuantity IS NULL
    BEGIN
        RAISERROR('El producto no existe en la tienda origen', 16, 1);
        RETURN;
    END
    
    IF @SourceQuantity < @Quantity
    BEGIN
        RAISERROR('Inventario insuficiente en tienda origen. Disponible: %d, Solicitado: %d', 
                 16, 1, @SourceQuantity, @Quantity);
        RETURN;
    END
    
    -- Iniciar la transacción
    BEGIN TRY
        -- Usar nivel de aislamiento SERIALIZABLE para prevenir problemas de concurrencia
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
        
        BEGIN TRANSACTION;
        
        -- Reducir inventario en tienda origen
        UPDATE Inventory.StoreInventory
        SET QuantityInStock = QuantityInStock - @Quantity
        WHERE StoreID = @SourceStoreID AND ProductID = @ProductID;
        
        -- Verificar si el producto ya existe en tienda destino
        IF EXISTS (SELECT 1 FROM Inventory.StoreInventory 
                  WHERE StoreID = @TargetStoreID AND ProductID = @ProductID)
        BEGIN
            -- Actualizar inventario existente
            UPDATE Inventory.StoreInventory
            SET QuantityInStock = QuantityInStock + @Quantity
            WHERE StoreID = @TargetStoreID AND ProductID = @ProductID;
        END
        ELSE
        BEGIN
            -- Crear nuevo registro de inventario
            INSERT INTO Inventory.StoreInventory (
                StoreID, ProductID, QuantityInStock, StockDate
            )
            VALUES (
                @TargetStoreID, @ProductID, @Quantity, GETDATE()
            );
        END
        
        -- Registrar transacción de salida
        INSERT INTO Inventory.InventoryTransaction (
            StoreID, ProductID, TransactionType, Quantity,
            SourceStoreID, EmployeeID, Notes
        )
        VALUES (
            @SourceStoreID, @ProductID, 'Transfer', -@Quantity,
            @TargetStoreID, @EmployeeID, 
            'Transferencia a tienda ' + CAST(@TargetStoreID AS VARCHAR)
        );
        
        -- Registrar transacción de entrada
        INSERT INTO Inventory.InventoryTransaction (
            StoreID, ProductID, TransactionType, Quantity,
            SourceStoreID, EmployeeID, Notes
        )
        VALUES (
            @TargetStoreID, @ProductID, 'Transfer', @Quantity,
            @SourceStoreID, @EmployeeID,
            'Transferencia desde tienda ' + CAST(@SourceStoreID AS VARCHAR)
        );
        
        COMMIT TRANSACTION;
        
        PRINT 'Transferencia de inventario completada con éxito';
    END TRY
    BEGIN CATCH
        -- Si hay error, revertir todos los cambios
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        PRINT 'Error en la transferencia: ' + ERROR_MESSAGE();
        
        -- Re-lanzar el error para que la aplicación pueda manejarlo
        THROW;
    END CATCH;
END;
GO