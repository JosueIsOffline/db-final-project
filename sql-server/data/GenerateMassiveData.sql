/*
    Retail Chain Management System - Script de Generación de Datos Corregido
    Final Project - Advanced Database
    ITLA
*/

USE RetailChainDB;
GO

-- Configuración para permitir inserciones masivas más rápidas
SET NOCOUNT ON;

-- Variables para controlar la cantidad de datos a generar (reducidas para probar)
DECLARE @CountryCount INT = 3;                -- Mantiene igual (constante)
DECLARE @RegionsPerCountry INT = 3;           -- Mantiene igual (constante)  
DECLARE @CitiesPerRegion INT = 3;             -- Mantiene igual (constante)
DECLARE @StoreTypesCount INT = 5;             -- Mantiene igual (constante)
DECLARE @StoresPerCity INT = 2;               -- Aumentado de 1 a 2 (54 tiendas)
DECLARE @DepartmentsCount INT = 5;            -- Mantiene igual (constante)
DECLARE @PositionsPerDepartment INT = 3;      -- Mantiene igual (constante)
DECLARE @EmployeesPerStore INT = 15;          -- Aumentado de 5 a 15 (810 empleados)
DECLARE @CategoryCount INT = 10;              -- Mantiene igual (constante)
DECLARE @SuppliersCount INT = 50;             -- Aumentado de 20 a 50
DECLARE @ProductsPerCategory INT = 25;        -- Aumentado de 10 a 25 (250 productos)
DECLARE @LoyaltyLevelsCount INT = 4;          -- Mantiene igual (constante)
DECLARE @CustomersCount INT = 1000;           -- Aumentado de 200 a 1000
DECLARE @PaymentMethodsCount INT = 5;         -- Mantiene igual (constante)
DECLARE @PromotionsCount INT = 20;            -- Aumentado de 10 a 20
DECLARE @SalesCount INT = 500;                -- Aumentado de 50 a 500
DECLARE @MaxItemsPerSale INT = 5;             -- Aumentado de 3 a 5

PRINT 'Iniciando generación de datos...';
PRINT CONVERT(VARCHAR, GETDATE(), 120);

-- Limpiar datos existentes (en orden inverso debido a las restricciones de clave foránea)
PRINT 'Limpiando datos existentes...';

-- Primero desactivamos las restricciones de FK para facilitar la limpieza
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';

-- Truncar/eliminar datos existentes
DELETE FROM Audit.LoginAttempt;
DELETE FROM Audit.EmployeeHistory;
DELETE FROM Audit.PriceHistory;
DELETE FROM Audit.SchemaChanges;
DELETE FROM Sales.SaleDetail;
DELETE FROM Sales.Sale;
DELETE FROM Sales.ProductPromotion;
DELETE FROM Sales.Promotion;
DELETE FROM Sales.Customer;
DELETE FROM Sales.LoyaltyLevel;
DELETE FROM Sales.PaymentMethod;
DELETE FROM Inventory.InventoryTransaction;
DELETE FROM Inventory.StoreInventory;
DELETE FROM Inventory.Product;
DELETE FROM Inventory.Supplier;
DELETE FROM Inventory.Category;
DELETE FROM HR.Schedule;
DELETE FROM HR.Employee;
DELETE FROM HR.Position;
DELETE FROM HR.Department;
DELETE FROM Store.Store;
DELETE FROM Store.StoreType;
DELETE FROM Store.City;
DELETE FROM Store.Region;
DELETE FROM Store.Country;

-- Resetting IDENTITY columns
DBCC CHECKIDENT ('Audit.LoginAttempt', RESEED, 0);
DBCC CHECKIDENT ('Audit.EmployeeHistory', RESEED, 0);
DBCC CHECKIDENT ('Audit.PriceHistory', RESEED, 0);
DBCC CHECKIDENT ('Audit.SchemaChanges', RESEED, 0);
DBCC CHECKIDENT ('Sales.SaleDetail', RESEED, 0);
DBCC CHECKIDENT ('Sales.Sale', RESEED, 0);
DBCC CHECKIDENT ('Sales.ProductPromotion', RESEED, 0);
DBCC CHECKIDENT ('Sales.Promotion', RESEED, 0);
DBCC CHECKIDENT ('Sales.Customer', RESEED, 0);
DBCC CHECKIDENT ('Sales.LoyaltyLevel', RESEED, 0);
DBCC CHECKIDENT ('Sales.PaymentMethod', RESEED, 0);
DBCC CHECKIDENT ('Inventory.InventoryTransaction', RESEED, 0);
DBCC CHECKIDENT ('Inventory.StoreInventory', RESEED, 0);
DBCC CHECKIDENT ('Inventory.Product', RESEED, 0);
DBCC CHECKIDENT ('Inventory.Supplier', RESEED, 0);
DBCC CHECKIDENT ('Inventory.Category', RESEED, 0);
DBCC CHECKIDENT ('HR.Schedule', RESEED, 0);
DBCC CHECKIDENT ('HR.Employee', RESEED, 0);
DBCC CHECKIDENT ('HR.Position', RESEED, 0);
DBCC CHECKIDENT ('HR.Department', RESEED, 0);
DBCC CHECKIDENT ('Store.Store', RESEED, 0);
DBCC CHECKIDENT ('Store.StoreType', RESEED, 0);
DBCC CHECKIDENT ('Store.City', RESEED, 0);
DBCC CHECKIDENT ('Store.Region', RESEED, 0);
DBCC CHECKIDENT ('Store.Country', RESEED, 0);

-- Volvemos a activar las restricciones de FK
EXEC sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL';

PRINT 'Generando datos para países...';

-- Insertar Países
INSERT INTO Store.Country (CountryName, CountryCode, IsActive)
VALUES 
    ('Mexico', 'MX', 1),
    ('United States', 'US', 1),
    ('Canada', 'CA', 1);

PRINT 'Generando datos para regiones...';

-- Insertar Regiones
DECLARE @CountryID INT = 1;

WHILE @CountryID <= @CountryCount
BEGIN
    DECLARE @r INT = 1;
    
    WHILE @r <= @RegionsPerCountry
    BEGIN
        INSERT INTO Store.Region (RegionName, CountryID, IsActive)
        VALUES (
            CASE 
                WHEN @CountryID = 1 THEN -- Mexico
                    CASE @r
                        WHEN 1 THEN 'Norte'
                        WHEN 2 THEN 'Centro'
                        WHEN 3 THEN 'Sur'
                    END
                WHEN @CountryID = 2 THEN -- USA
                    CASE @r
                        WHEN 1 THEN 'East Coast'
                        WHEN 2 THEN 'Midwest'
                        WHEN 3 THEN 'West Coast'
                    END
                ELSE -- Canada
                    CASE @r
                        WHEN 1 THEN 'Atlantic'
                        WHEN 2 THEN 'Central'
                        WHEN 3 THEN 'Pacific'
                    END
            END,
            @CountryID,
            1
        );
        
        SET @r = @r + 1;
    END
    
    SET @CountryID = @CountryID + 1;
END

PRINT 'Generando datos para ciudades...';

-- Insertar Ciudades
DECLARE @RegionID INT = 1;
DECLARE @MaxRegionID INT = @CountryCount * @RegionsPerCountry;

WHILE @RegionID <= @MaxRegionID
BEGIN
    DECLARE @c INT = 1;
    DECLARE @CountryIDForRegion INT;
    
    SELECT @CountryIDForRegion = CountryID FROM Store.Region WHERE RegionID = @RegionID;
    
    WHILE @c <= @CitiesPerRegion
    BEGIN
        INSERT INTO Store.City (CityName, RegionID, PostalCode, IsActive)
        VALUES (
            CASE 
                WHEN @CountryIDForRegion = 1 THEN -- Mexico
                    CASE 
                        WHEN @RegionID = 1 THEN -- Norte
                            CASE @c
                                WHEN 1 THEN 'Monterrey'
                                WHEN 2 THEN 'Chihuahua'
                                WHEN 3 THEN 'Torreón'
                            END
                        WHEN @RegionID = 2 THEN -- Centro
                            CASE @c
                                WHEN 1 THEN 'Ciudad de México'
                                WHEN 2 THEN 'Puebla'
                                WHEN 3 THEN 'Querétaro'
                            END
                        ELSE -- Sur
                            CASE @c
                                WHEN 1 THEN 'Mérida'
                                WHEN 2 THEN 'Cancún'
                                WHEN 3 THEN 'Oaxaca'
                            END
                    END
                WHEN @CountryIDForRegion = 2 THEN -- USA
                    CASE 
                        WHEN @RegionID = 4 THEN -- East Coast
                            CASE @c
                                WHEN 1 THEN 'New York'
                                WHEN 2 THEN 'Miami'
                                WHEN 3 THEN 'Boston'
                            END
                        WHEN @RegionID = 5 THEN -- Midwest
                            CASE @c
                                WHEN 1 THEN 'Chicago'
                                WHEN 2 THEN 'Detroit'
                                WHEN 3 THEN 'St. Louis'
                            END
                        ELSE -- West Coast
                            CASE @c
                                WHEN 1 THEN 'Los Angeles'
                                WHEN 2 THEN 'San Francisco'
                                WHEN 3 THEN 'Seattle'
                            END
                    END
                ELSE -- Canada
                    CASE 
                        WHEN @RegionID = 7 THEN -- Atlantic
                            CASE @c
                                WHEN 1 THEN 'Halifax'
                                WHEN 2 THEN 'St. John''s'
                                WHEN 3 THEN 'Moncton'
                            END
                        WHEN @RegionID = 8 THEN -- Central
                            CASE @c
                                WHEN 1 THEN 'Toronto'
                                WHEN 2 THEN 'Montreal'
                                WHEN 3 THEN 'Ottawa'
                            END
                        ELSE -- Pacific
                            CASE @c
                                WHEN 1 THEN 'Vancouver'
                                WHEN 2 THEN 'Victoria'
                                WHEN 3 THEN 'Calgary'
                            END
                    END
            END,
            @RegionID,
            CONCAT(CAST((@RegionID * 1000) AS NVARCHAR), CAST((@c * 100) AS NVARCHAR)),
            1
        );
        
        SET @c = @c + 1;
    END
    
    SET @RegionID = @RegionID + 1;
END

PRINT 'Generando datos para tipos de tienda...';

-- Insertar tipos de tienda
INSERT INTO Store.StoreType (TypeName, Description, IsActive)
VALUES 
    ('Mall', 'Ubicadas en centros comerciales', 1),
    ('Street', 'Tiendas con acceso directo a la calle', 1),
    ('Outlet', 'Tiendas de descuento', 1),
    ('Express', 'Tiendas pequeñas de conveniencia', 1),
    ('Flagship', 'Tiendas insignia de gran tamaño', 1);

PRINT 'Generando datos para departamentos...';

-- Insertar departamentos
INSERT INTO HR.Department (DepartmentName, Description, IsActive)
VALUES 
    ('Sales', 'Departamento de ventas', 1),
    ('Management', 'Departamento de gerencia', 1),
    ('Inventory', 'Departamento de inventario y almacén', 1),
    ('Customer Service', 'Departamento de atención al cliente', 1),
    ('Finance', 'Departamento de finanzas', 1);

PRINT 'Generando datos para posiciones...';

-- Insertar posiciones de trabajo
DECLARE @DeptID INT = 1;

WHILE @DeptID <= @DepartmentsCount
BEGIN
    DECLARE @p INT = 1;
    
    WHILE @p <= @PositionsPerDepartment
    BEGIN
        INSERT INTO HR.Position (PositionTitle, DepartmentID, MinSalary, MaxSalary, IsActive)
        VALUES (
            CASE 
                WHEN @DeptID = 1 THEN -- Sales
                    CASE @p
                        WHEN 1 THEN 'Sales Associate'
                        WHEN 2 THEN 'Sales Supervisor'
                        WHEN 3 THEN 'Sales Manager'
                    END
                WHEN @DeptID = 2 THEN -- Management
                    CASE @p
                        WHEN 1 THEN 'Assistant Manager'
                        WHEN 2 THEN 'Store Manager'
                        WHEN 3 THEN 'Regional Manager'
                    END
                WHEN @DeptID = 3 THEN -- Inventory
                    CASE @p
                        WHEN 1 THEN 'Warehouse Staff'
                        WHEN 2 THEN 'Inventory Clerk'
                        WHEN 3 THEN 'Inventory Manager'
                    END
                WHEN @DeptID = 4 THEN -- Customer Service
                    CASE @p
                        WHEN 1 THEN 'Customer Service Rep'
                        WHEN 2 THEN 'Customer Service Lead'
                        WHEN 3 THEN 'Customer Service Manager'
                    END
                ELSE -- Finance
                    CASE @p
                        WHEN 1 THEN 'Cashier'
                        WHEN 2 THEN 'Accountant'
                        WHEN 3 THEN 'Finance Manager'
                    END
            END,
            @DeptID,
            CASE @p
                WHEN 1 THEN 12000.00
                WHEN 2 THEN 18000.00
                WHEN 3 THEN 25000.00
            END,
            CASE @p
                WHEN 1 THEN 20000.00
                WHEN 2 THEN 30000.00
                WHEN 3 THEN 50000.00
            END,
            1
        );
        
        SET @p = @p + 1;
    END
    
    SET @DeptID = @DeptID + 1;
END

PRINT 'Generando datos para tiendas...';

-- Insertar tiendas
DECLARE @CityID INT = 1;
DECLARE @MaxCityID INT = @MaxRegionID * @CitiesPerRegion;
DECLARE @StoreCount INT = 0;

WHILE @CityID <= @MaxCityID
BEGIN
    DECLARE @s INT = 1;
    
    WHILE @s <= @StoresPerCity
    BEGIN
        DECLARE @StoreTypeID INT = CAST(((@CityID * 10 + @s) % @StoreTypesCount) + 1 AS INT);
        DECLARE @StoreName NVARCHAR(100);
        DECLARE @StoreSize DECIMAL(10, 2);
        
        SELECT @StoreName = CONCAT('Store ', CityName, ' ', @s) FROM Store.City WHERE CityID = @CityID;
        
        SET @StoreSize = CASE @StoreTypeID
            WHEN 1 THEN 500.00 + (RAND() * 1000) -- Mall
            WHEN 2 THEN 300.00 + (RAND() * 500)  -- Street
            WHEN 3 THEN 800.00 + (RAND() * 1200) -- Outlet
            WHEN 4 THEN 100.00 + (RAND() * 200)  -- Express
            WHEN 5 THEN 1000.00 + (RAND() * 2000) -- Flagship
        END;
        
        INSERT INTO Store.Store (
            StoreName, 
            StoreCode, 
            StoreTypeID, 
            Address, 
            CityID, 
            Phone, 
            Email, 
            OpeningDate, 
            Size, 
            IsActive
        )
        VALUES (
            @StoreName,
            CONCAT('ST', RIGHT('000' + CAST(@StoreCount + 1 AS NVARCHAR(3)), 3)),
            @StoreTypeID,
            CONCAT('Av. Principal ', CAST((@s * 100) AS NVARCHAR), ', Local ', CAST(@s AS NVARCHAR)),
            @CityID,
            CONCAT('+', CASE 
                WHEN @CityID <= 9 THEN '52' -- Mexico
                WHEN @CityID <= 18 THEN '1' -- USA
                ELSE '1' -- Canada
            END, ' ', CAST((555000000 + @StoreCount * 1000) AS NVARCHAR)),
            CONCAT('store', @StoreCount + 1, '@retailchain.com'),
            DATEADD(YEAR, -CAST(RAND() * 10 AS INT), GETDATE()),
            @StoreSize,
            1
        );
        
        SET @s = @s + 1;
        SET @StoreCount = @StoreCount + 1;
    END
    
    SET @CityID = @CityID + 1;
END

-- Verificación: Guardar el número total de tiendas creadas
DECLARE @TotalStores INT;
SELECT @TotalStores = COUNT(*) FROM Store.Store;
PRINT CONCAT('Total de tiendas creadas: ', @TotalStores);

PRINT 'Generando datos para categorías de productos...';

-- Insertar categorías de productos (reducidas a 10)
INSERT INTO Inventory.Category (CategoryName, ParentCategoryID, Description, IsActive)
VALUES 
    ('Electronics', NULL, 'Electronic devices and gadgets', 1),
    ('Computers', 1, 'Computers and accessories', 1),
    ('TVs', 1, 'Television sets and monitors', 1),
    ('Audio', 1, 'Audio equipment', 1),
    ('Mobile Phones', 1, 'Smartphones and accessories', 1),
    ('Home', NULL, 'Home products', 1),
    ('Kitchen', 6, 'Kitchen appliances and tools', 1),
    ('Bathroom', 6, 'Bathroom items', 1),
    ('Garden', 6, 'Garden tools and accessories', 1),
    ('Furniture', 6, 'Home furniture', 1);

PRINT 'Generando datos para proveedores...';

-- Insertar proveedores
DECLARE @SupplierID INT = 1;

WHILE @SupplierID <= @SuppliersCount
BEGIN
    DECLARE @SupplierCityID INT = CAST(RAND() * @MaxCityID + 1 AS INT);
    
    INSERT INTO Inventory.Supplier (
        SupplierName, 
        ContactName, 
        ContactEmail, 
        ContactPhone, 
        Address, 
        CityID, 
        TaxID, 
        IsActive
    )
    VALUES (
        CONCAT('Supplier ', @SupplierID),
        CONCAT('Contact ', @SupplierID),
        CONCAT('contact', @SupplierID, '@supplier', @SupplierID, '.com'),
        CONCAT('+', CASE 
            WHEN @SupplierCityID <= 9 THEN '52' -- Mexico
            WHEN @SupplierCityID <= 18 THEN '1' -- USA
            ELSE '1' -- Canada
        END, ' ', CAST((888000000 + @SupplierID * 1000) AS NVARCHAR)),
        CONCAT('Industrial Street #', @SupplierID, ', Industrial Zone'),
        @SupplierCityID,
        CONCAT('TAX', RIGHT('00000' + CAST(@SupplierID AS NVARCHAR(5)), 5)),
        1
    );
    
    SET @SupplierID = @SupplierID + 1;
END

PRINT 'Generando datos para niveles de lealtad...';

-- Insertar niveles de lealtad
INSERT INTO Sales.LoyaltyLevel (LevelName, MinimumPoints, DiscountPercentage, OtherBenefits, IsActive)
VALUES 
    ('Standard', 0, 0.00, 'Basic benefits', 1),
    ('Silver', 1000, 5.00, 'Free shipping on orders over $50', 1),
    ('Gold', 5000, 10.00, 'Free shipping, exclusive offers', 1),
    ('Platinum', 10000, 15.00, 'Free shipping, exclusive offers, priority service', 1);

PRINT 'Generando datos para métodos de pago...';

-- Insertar métodos de pago
INSERT INTO Sales.PaymentMethod (MethodName, Description, IsActive)
VALUES 
    ('Cash', 'Cash payment in store', 1),
    ('Credit Card', 'Payment with credit cards (Visa, MasterCard, etc.)', 1),
    ('Debit Card', 'Payment with debit cards', 1),
    ('Bank Transfer', 'Direct bank transfer', 1),
    ('Digital Wallet', 'Payment through digital wallets', 1);

PRINT 'Generando datos para productos...';

-- Insertar productos
DECLARE @ProductID INT = 1;
DECLARE @CategoryID INT = 1;

WHILE @CategoryID <= @CategoryCount
BEGIN
    DECLARE @j INT = 1;
    
    WHILE @j <= @ProductsPerCategory
    BEGIN
        DECLARE @SupplierIDForProduct INT = CAST(RAND() * @SuppliersCount + 1 AS INT);
        DECLARE @BasePrice DECIMAL(10, 2) = CAST(RAND() * 10000 + 50 AS DECIMAL(10, 2));
        DECLARE @CostPrice DECIMAL(10, 2) = @BasePrice * 0.6; -- 40% margin
        DECLARE @RetailPrice DECIMAL(10, 2) = @BasePrice;
        DECLARE @DiscountPrice DECIMAL(10, 2) = NULL;
        
        -- Sometimes apply a discount
        IF RAND() > 0.7
            SET @DiscountPrice = @RetailPrice * 0.9; -- 10% discount
        
        INSERT INTO Inventory.Product (
            ProductName,
            ProductCode,
            SKU,
            Barcode,
            Description,
            CategoryID,
            SupplierID,
            CostPrice,
            RetailPrice,
            DiscountPrice,
            Weight,
            Dimensions,
            IsPerishable,
            MinStockLevel,
            MaxStockLevel,
            ReorderPoint,
            IsActive
        )
        VALUES (
            CONCAT('Product ', @CategoryID, '-', @j),
            CONCAT('PROD-', RIGHT('000' + CAST(@ProductID AS NVARCHAR(3)), 3)),
            CONCAT('SKU-', RIGHT('000' + CAST(@CategoryID AS NVARCHAR(3)), 3), '-', RIGHT('000' + CAST(@j AS NVARCHAR(3)), 3)),
            CONCAT('BAR', RIGHT('00000000' + CAST(@ProductID AS NVARCHAR(8)), 8)),
            CONCAT('Description for product ', @CategoryID, '-', @j, '. High quality product.'),
            @CategoryID,
            @SupplierIDForProduct,
            @CostPrice,
            @RetailPrice,
            @DiscountPrice,
            CAST(RAND() * 20 + 0.1 AS DECIMAL(8, 2)),
            CONCAT(CAST(CAST(RAND() * 100 + 10 AS INT) AS NVARCHAR), 'x', 
                  CAST(CAST(RAND() * 100 + 10 AS INT) AS NVARCHAR), 'x', 
                  CAST(CAST(RAND() * 100 + 10 AS INT) AS NVARCHAR), ' cm'),
            CASE WHEN @CategoryID >= 6 THEN 1 ELSE 0 END, -- Items from category 6+ are perishable
            10,
            100,
            20,
            1
        );
        
        SET @j = @j + 1;
        SET @ProductID = @ProductID + 1;
    END
    
    SET @CategoryID = @CategoryID + 1;
END

PRINT 'Generando datos para empleados...';

-- Variable para rastrear el número total de tiendas reales en la base de datos
DECLARE @ActualTotalStores INT;
SELECT @ActualTotalStores = COUNT(*) FROM Store.Store;

-- Insertar empleados
DECLARE @EmployeeID INT = 1;
DECLARE @StoreID INT = 1;

WHILE @StoreID <= @ActualTotalStores
BEGIN
    -- Primero insertar al gerente de la tienda
    DECLARE @ManagerPositionID INT;
    SELECT TOP 1 @ManagerPositionID = PositionID FROM HR.Position 
    WHERE PositionTitle LIKE '%Manager%' 
    ORDER BY NEWID();
    
    INSERT INTO HR.Employee (
        FirstName,
        LastName,
        EmployeeCode,
        Email,
        Phone,
        HireDate,
        BirthDate,
        Gender,
        Address,
        CityID,
        PositionID,
        StoreID,
        ReportsTo,
        Salary,
        IsActive
    )
    VALUES (
        CONCAT('Manager', @StoreID),
        CONCAT('Surname', @StoreID),
        CONCAT('EMP', RIGHT('00000' + CAST(@EmployeeID AS NVARCHAR(5)), 5)),
        CONCAT('manager', @StoreID, '@retailchain.com'),
        CONCAT('+1234567', RIGHT('0000' + CAST(@EmployeeID AS NVARCHAR(4)), 4)),
        DATEADD(YEAR, -CAST(RAND() * 5 + 1 AS INT), GETDATE()),
        DATEADD(YEAR, -CAST(RAND() * 25 + 25 AS INT), GETDATE()),
        CASE WHEN @EmployeeID % 2 = 0 THEN 'M' ELSE 'F' END,
        CONCAT('Address Employee ', @EmployeeID),
        (SELECT CityID FROM Store.Store WHERE StoreID = @StoreID),
        @ManagerPositionID,
        @StoreID,
        NULL, -- No tiene supervisor
        30000 + (RAND() * 20000), -- Salario entre 30000 y 50000
        1
    );
    
    -- Guardar el ID del gerente
    DECLARE @StoreManagerID INT = @EmployeeID;
    SET @EmployeeID = @EmployeeID + 1;
    
    -- Actualizar la tienda con el ID del gerente
    UPDATE Store.Store
    SET ManagerID = @StoreManagerID
    WHERE StoreID = @StoreID;
    
    -- Insertar resto de empleados para esta tienda
    DECLARE @e INT = 1;
    
    WHILE @e < @EmployeesPerStore
    BEGIN
        DECLARE @PositionID INT;
        SELECT TOP 1 @PositionID = PositionID FROM HR.Position 
        WHERE PositionID <> @ManagerPositionID 
        ORDER BY NEWID();
        
        INSERT INTO HR.Employee (
            FirstName,
            LastName,
            EmployeeCode,
            Email,
            Phone,
            HireDate,
            BirthDate,
            Gender,
            Address,
            CityID,
            PositionID,
            StoreID,
            ReportsTo,
            Salary,
            IsActive
        )
        VALUES (
            CONCAT('Name', @EmployeeID),
            CONCAT('Surname', @EmployeeID),
            CONCAT('EMP', RIGHT('00000' + CAST(@EmployeeID AS NVARCHAR(5)), 5)),
            CONCAT('employee', @EmployeeID, '@retailchain.com'),
            CONCAT('+1234567', RIGHT('0000' + CAST(@EmployeeID AS NVARCHAR(4)), 4)),
            DATEADD(YEAR, -CAST(RAND() * 3 + 0.1 AS FLOAT), GETDATE()),
            DATEADD(YEAR, -CAST(RAND() * 25 + 20 AS INT), GETDATE()),
            CASE WHEN @EmployeeID % 2 = 0 THEN 'M' ELSE 'F' END,
            CONCAT('Address Employee ', @EmployeeID),
            (SELECT CityID FROM Store.Store WHERE StoreID = @StoreID),
            @PositionID,
            @StoreID,
            @StoreManagerID, -- Reportan al gerente de la tienda
            12000 + (RAND() * 18000), -- Salario entre 12000 y 30000
            1
        );
        
        SET @e = @e + 1;
        SET @EmployeeID = @EmployeeID + 1;
    END
    
    SET @StoreID = @StoreID + 1;
END

PRINT 'Generando datos para clientes...';

-- Insertar clientes
DECLARE @CustomerID INT = 1;

WHILE @CustomerID <= @CustomersCount
BEGIN
    DECLARE @CustomerCityID INT = CAST(RAND() * @MaxCityID + 1 AS INT);
    DECLARE @LoyaltyLevelID INT = CASE 
        WHEN @CustomerID % 100 = 0 THEN 4 -- Platinum
        WHEN @CustomerID % 20 = 0 THEN 3  -- Gold
        WHEN @CustomerID % 5 = 0 THEN 2   -- Silver
        ELSE 1                            -- Standard
    END;

	-- Generar un número de tarjeta único para todos, no solo para niveles superiores
    DECLARE @LoyaltyCardNumber NVARCHAR(50) = CONCAT('LC', RIGHT('00000' + CAST(@CustomerID AS NVARCHAR(5)), 5));
    
   INSERT INTO Sales.Customer (
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
        JoinDate
    )
    VALUES (
        CONCAT('Customer', RIGHT('00000' + CAST(@CustomerID AS NVARCHAR(5)), 5)),
        CONCAT('Surname', RIGHT('00000' + CAST(@CustomerID AS NVARCHAR(5)), 5)),
        CONCAT('customer', @CustomerID, '@email.com'),
        CONCAT('+9876543', RIGHT('0000' + CAST(@CustomerID AS NVARCHAR(4)), 4)),
        CONCAT('Customer Street #', @CustomerID),
        @CustomerCityID,
        @LoyaltyCardNumber, -- Siempre asignamos un valor único
        CASE 
            WHEN @LoyaltyLevelID = 1 THEN CAST(RAND() * 999 AS INT)
            WHEN @LoyaltyLevelID = 2 THEN CAST(RAND() * 4000 + 1000 AS INT)
            WHEN @LoyaltyLevelID = 3 THEN CAST(RAND() * 5000 + 5000 AS INT)
            ELSE CAST(RAND() * 10000 + 10000 AS INT)
        END,
        @LoyaltyLevelID,
        DATEADD(YEAR, -CAST(RAND() * 50 + 18 AS INT), GETDATE()),
        CASE WHEN @CustomerID % 3 = 0 THEN 'M' WHEN @CustomerID % 3 = 1 THEN 'F' ELSE 'O' END,
        1,
        DATEADD(DAY, -CAST(RAND() * 1000 AS INT), GETDATE())
    );
    
    SET @CustomerID = @CustomerID + 1;
END

PRINT 'Generando datos para inventario de tiendas...';

-- Insertar inventario de tiendas (asegurándonos de usar StoreIDs válidos)
-- Primero obtenemos el número real de productos
DECLARE @TotalProducts INT;
SELECT @TotalProducts = COUNT(*) FROM Inventory.Product;
PRINT CONCAT('Total de productos creados: ', @TotalProducts);

-- Luego insertamos inventario solo para combinaciones válidas de tienda y producto
INSERT INTO Inventory.StoreInventory (StoreID, ProductID, QuantityInStock, StockDate, LastRestockDate)
SELECT 
    s.StoreID,
    p.ProductID,
    CAST(RAND() * 100 + 10 AS INT), -- Stock between 10 and 110
    GETDATE(),
    DATEADD(DAY, -CAST(RAND() * 30 AS INT), GETDATE()) -- Last restock in the last 30 days
FROM 
    Store.Store s
CROSS JOIN 
    Inventory.Product p
WHERE 
    -- Para limitar la cantidad de registros y evitar que todos los productos estén en todas las tiendas
    (s.StoreID % 3 = p.ProductID % 3);

PRINT 'Generando datos para promociones...';

-- Insertar promociones
DECLARE @PromotionID INT = 1;

WHILE @PromotionID <= @PromotionsCount
BEGIN
    DECLARE @StartDate DATE = DATEADD(DAY, -CAST(RAND() * 60 AS INT), GETDATE());
    DECLARE @EndDate DATE = DATEADD(DAY, CAST(RAND() * 60 + 30 AS INT), @StartDate);
    DECLARE @DiscountType NVARCHAR(20) = CASE 
        WHEN @PromotionID % 3 = 0 THEN 'Percentage'
        WHEN @PromotionID % 3 = 1 THEN 'FixedAmount'
        ELSE 'BuyXGetY'
    END;
    DECLARE @DiscountValue DECIMAL(10, 2);
    
    IF @DiscountType = 'Percentage'
        SET @DiscountValue = CAST(RAND() * 40 + 5 AS DECIMAL(10, 2)); -- 5% to 45%
    ELSE
        SET @DiscountValue = CAST(RAND() * 500 + 50 AS DECIMAL(10, 2)); -- $50 to $550
    
    INSERT INTO Sales.Promotion (
        PromotionName,
        Description,
        StartDate,
        EndDate,
        DiscountType,
        DiscountValue,
        MinimumPurchase,
        IsActive
    )
    VALUES (
        CONCAT('Promotion ', @PromotionID),
        CONCAT('Description for promotion ', @PromotionID),
        @StartDate,
        @EndDate,
        @DiscountType,
        @DiscountValue,
        CAST(RAND() * 1000 AS DECIMAL(10, 2)), -- Min purchase $0 to $1000
        CASE WHEN @StartDate <= GETDATE() AND @EndDate >= GETDATE() THEN 1 ELSE 0 END
    );
    
    SET @PromotionID = @PromotionID + 1;
END

PRINT 'Generando datos para product-promotion...';

-- Enlazar algunos productos con promociones
INSERT INTO Sales.ProductPromotion (ProductID, PromotionID)
SELECT 
    p.ProductID,
    pm.PromotionID
FROM 
    Inventory.Product p,
    Sales.Promotion pm
WHERE 
    p.ProductID % 10 = pm.PromotionID % 10 -- Solo asociamos algunos productos
    AND NOT EXISTS (
        SELECT 1 FROM Sales.ProductPromotion pp 
        WHERE pp.ProductID = p.ProductID AND pp.PromotionID = pm.PromotionID
    );

PRINT 'Generando datos para ventas y detalles de ventas...';

-- Insertar ventas y detalles de ventas usando variables que verifiquen la existencia
DECLARE @SaleID INT = 1;

WHILE @SaleID <= @SalesCount
BEGIN
    -- Para cada venta, seleccionamos una tienda aleatoria que realmente exista
    DECLARE @SaleStoreID INT;
    SELECT TOP 1 @SaleStoreID = StoreID 
    FROM Store.Store 
    ORDER BY NEWID();
    
    IF @SaleStoreID IS NULL
    BEGIN
        PRINT 'Error: No se encontraron tiendas válidas. Abortando la generación de ventas.';
        BREAK;
    END
    
    -- Seleccionamos un empleado aleatorio de esa tienda
    DECLARE @SaleEmployeeID INT;
    SELECT TOP 1 @SaleEmployeeID = EmployeeID 
    FROM HR.Employee 
    WHERE StoreID = @SaleStoreID
    ORDER BY NEWID();
    
    IF @SaleEmployeeID IS NULL
    BEGIN
        PRINT CONCAT('Error: No se encontraron empleados para la tienda ', @SaleStoreID, '. Omitiendo esta venta.');
        SET @SaleID = @SaleID + 1;
        CONTINUE;
    END
    
    -- Seleccionamos un cliente aleatorio o NULL (compra sin registro de cliente)
    DECLARE @SaleCustomerID INT = NULL;
    IF RAND() > 0.3 -- 70% de las ventas tienen cliente registrado
    BEGIN
        SELECT TOP 1 @SaleCustomerID = CustomerID 
        FROM Sales.Customer 
        ORDER BY NEWID();
    END
    
    -- Seleccionamos un método de pago aleatorio
    DECLARE @SalePaymentMethodID INT;
    SELECT TOP 1 @SalePaymentMethodID = PaymentMethodID 
    FROM Sales.PaymentMethod 
    ORDER BY NEWID();
    
    IF @SalePaymentMethodID IS NULL
    BEGIN
        PRINT 'Error: No se encontraron métodos de pago. Omitiendo esta venta.';
        SET @SaleID = @SaleID + 1;
        CONTINUE;
    END
    
    -- Determinamos una fecha aleatoria para la venta (en los últimos 365 días)
    DECLARE @SaleDate DATETIME = DATEADD(DAY, -CAST(RAND() * 365 AS INT), GETDATE());
    
    -- Seleccionamos una promoción aleatoria activa en esa fecha (puede ser NULL)
    DECLARE @SalePromotionID INT = NULL;
    IF RAND() > 0.7 -- 30% de las ventas tienen promoción
    BEGIN
        SELECT TOP 1 @SalePromotionID = PromotionID 
        FROM Sales.Promotion 
        WHERE StartDate <= @SaleDate AND EndDate >= @SaleDate
        ORDER BY NEWID();
    END
    
    -- Variables para calcular totales
    DECLARE @SubTotal DECIMAL(10, 2) = 0;
    DECLARE @Discount DECIMAL(10, 2) = 0;
    DECLARE @TaxRate DECIMAL(5, 2) = 0.16; -- 16% IVA
    DECLARE @TaxAmount DECIMAL(10, 2) = 0;
    DECLARE @TotalAmount DECIMAL(10, 2) = 0;
    DECLARE @SaleNumber NVARCHAR(50) = CONCAT('S', FORMAT(@SaleDate, 'yyyyMMdd'), '-', RIGHT('0000' + CAST(@SaleID AS NVARCHAR(4)), 4));
    
    -- Insertamos la venta (con totales provisionales)
    BEGIN TRY
        INSERT INTO Sales.Sale (
            SaleNumber,
            StoreID,
            CustomerID,
            EmployeeID,
            SaleDate,
            SubTotal,
            TaxAmount,
            DiscountAmount,
            TotalAmount,
            PaymentMethodID,
            PaymentReference,
            LoyaltyPointsEarned,
            PromotionID,
            Status
        )
        VALUES (
            @SaleNumber,
            @SaleStoreID,
            @SaleCustomerID,
            @SaleEmployeeID,
            @SaleDate,
            0, -- Provisional
            0, -- Provisional
            0, -- Provisional
            0, -- Provisional
            @SalePaymentMethodID,
            CASE WHEN @SalePaymentMethodID > 1 THEN CONCAT('REF', RIGHT('000000' + CAST(@SaleID AS NVARCHAR(6)), 6)) ELSE NULL END,
            NULL, -- Se actualizará después
            @SalePromotionID,
            'Completed'
        );
    END TRY
    BEGIN CATCH
        PRINT CONCAT('Error al insertar venta #', @SaleID, ': ', ERROR_MESSAGE());
        SET @SaleID = @SaleID + 1;
        CONTINUE;
    END CATCH
    
    -- Determinamos cuántos ítems tiene esta venta (entre 1 y @MaxItemsPerSale)
    DECLARE @ItemCount INT = CAST(RAND() * @MaxItemsPerSale + 1 AS INT);
    DECLARE @ItemIndex INT = 1;
    
    WHILE @ItemIndex <= @ItemCount
    BEGIN
        -- Seleccionamos un producto que esté en el inventario de esta tienda
        DECLARE @SaleProductID INT;
        DECLARE @ProductUnitPrice DECIMAL(10, 2);
        DECLARE @ProductUnitCost DECIMAL(10, 2);
        DECLARE @AvailableStock INT;
        
        SELECT TOP 1 
            @SaleProductID = si.ProductID,
            @ProductUnitPrice = p.RetailPrice,
            @ProductUnitCost = p.CostPrice,
            @AvailableStock = si.QuantityInStock
        FROM Inventory.StoreInventory si
        INNER JOIN Inventory.Product p ON si.ProductID = p.ProductID
        WHERE si.StoreID = @SaleStoreID AND si.QuantityInStock > 0
        ORDER BY NEWID();
        
        -- Si no hay productos disponibles, salimos del bucle
        IF @SaleProductID IS NULL
        BEGIN
            PRINT CONCAT('No hay productos disponibles para la venta #', @SaleID);
            BREAK;
        END
            
        -- Determinamos la cantidad a vender (entre 1 y 3, pero no más que el stock disponible)
        DECLARE @Quantity INT = CASE 
            WHEN @AvailableStock <= 3 THEN 1
            ELSE CAST(RAND() * 3 + 1 AS INT)
        END;
        
        IF @Quantity > @AvailableStock
            SET @Quantity = @AvailableStock;
        
        -- Verificamos si el producto tiene descuento
        DECLARE @ItemDiscount DECIMAL(10, 2) = 0;
        DECLARE @UsedDiscountPrice DECIMAL(10, 2) = NULL;
        
        -- Check if the product has a discount price
        SELECT @UsedDiscountPrice = DiscountPrice
        FROM Inventory.Product
        WHERE ProductID = @SaleProductID AND DiscountPrice IS NOT NULL;
        
        IF @UsedDiscountPrice IS NOT NULL
            SET @ItemDiscount = (@ProductUnitPrice - @UsedDiscountPrice) * @Quantity;
        
        -- Calculamos los montos para este ítem
        DECLARE @ItemTaxRate DECIMAL(5, 2) = @TaxRate;
        DECLARE @ItemTaxAmount DECIMAL(10, 2) = ((@ProductUnitPrice * @Quantity) - @ItemDiscount) * @ItemTaxRate;
        DECLARE @LineTotal DECIMAL(10, 2) = ((@ProductUnitPrice * @Quantity) - @ItemDiscount) + @ItemTaxAmount;
        
        -- Insertamos el detalle de venta
        BEGIN TRY
            INSERT INTO Sales.SaleDetail (
                SaleID,
                ProductID,
                Quantity,
                UnitPrice,
                UnitCost,
                Discount,
                TaxRate,
                TaxAmount,
                LineTotal,
                ReturnedQuantity,
                ReturnReason
            )
            VALUES (
                @SaleID,
                @SaleProductID,
                @Quantity,
                @ProductUnitPrice,
                @ProductUnitCost,
                @ItemDiscount,
                @ItemTaxRate,
                @ItemTaxAmount,
                @LineTotal,
                0, -- No devueltos inicialmente
                NULL
            );
            
            -- Actualizamos los totales de la venta
            SET @SubTotal = @SubTotal + (@ProductUnitPrice * @Quantity);
            SET @Discount = @Discount + @ItemDiscount;
            SET @TaxAmount = @TaxAmount + @ItemTaxAmount;
            
            -- Actualizamos el inventario
            UPDATE Inventory.StoreInventory
            SET QuantityInStock = QuantityInStock - @Quantity
            WHERE StoreID = @SaleStoreID AND ProductID = @SaleProductID;
            
            -- Insertamos la transacción de inventario
            INSERT INTO Inventory.InventoryTransaction (
                StoreID,
                ProductID,
                TransactionType,
                Quantity,
                TransactionDate,
                EmployeeID,
                SaleID,
                Notes
            )
            VALUES (
                @SaleStoreID,
                @SaleProductID,
                'Sale',
                -@Quantity, -- Negativo porque es una reducción
                @SaleDate,
                @SaleEmployeeID,
                @SaleID,
                CONCAT('Sale transaction from sale ', @SaleNumber)
            );
        END TRY
        BEGIN CATCH
            PRINT CONCAT('Error al insertar detalle de venta #', @SaleID, ', ítem #', @ItemIndex, ': ', ERROR_MESSAGE());
        END CATCH
        
        SET @ItemIndex = @ItemIndex + 1;
    END
    
    -- Calculamos el total final
    SET @TotalAmount = (@SubTotal - @Discount) + @TaxAmount;
    
    -- Puntos de lealtad ganados (solo si hay cliente)
    DECLARE @LoyaltyPoints INT = NULL;
    IF @SaleCustomerID IS NOT NULL
    BEGIN
        SET @LoyaltyPoints = CAST(@TotalAmount / 100 AS INT); -- 1 punto por cada $100
        
        -- Actualizamos los puntos de lealtad del cliente
        UPDATE Sales.Customer
        SET 
            LoyaltyPoints = LoyaltyPoints + @LoyaltyPoints,
            LastPurchaseDate = @SaleDate
        WHERE CustomerID = @SaleCustomerID;
    END
    
    -- Actualizamos la venta con los totales calculados
    UPDATE Sales.Sale
    SET 
        SubTotal = @SubTotal,
        TaxAmount = @TaxAmount,
        DiscountAmount = @Discount,
        TotalAmount = @TotalAmount,
        LoyaltyPointsEarned = @LoyaltyPoints
    WHERE SaleID = @SaleID;
    
    SET @SaleID = @SaleID + 1;
    
    -- Mostrar progreso cada 10 ventas
    IF @SaleID % 10 = 0
        PRINT CONCAT('Procesadas ', @SaleID, ' de ', @SalesCount, ' ventas - ', CONVERT(VARCHAR, GETDATE(), 120));
END

PRINT 'Generando datos para horarios de trabajo...';

-- Generar algunos horarios de trabajo para los empleados
INSERT INTO HR.Schedule (EmployeeID, WorkDate, StartTime, EndTime)
SELECT 
    e.EmployeeID,
    DATEADD(DAY, n.n, DATEADD(DAY, -30, GETDATE())), -- Últimos 30 días
    DATEADD(HOUR, 8, 0), -- 8:00 AM
    DATEADD(HOUR, 17, 0) -- 5:00 PM
FROM 
    HR.Employee e
CROSS JOIN 
    (SELECT TOP 30 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n FROM sys.objects) n
WHERE 
    -- Solo para empleados activos y días de semana (no fines de semana)
    e.IsActive = 1
    AND DATEPART(WEEKDAY, DATEADD(DAY, n.n, DATEADD(DAY, -30, GETDATE()))) BETWEEN 2 AND 6
    AND e.EmployeeID % 5 = n.n % 5; -- Para limitar la cantidad de registros

PRINT 'Generando datos de auditoría y registros...';

-- Generar algunos registros de historial de precios
INSERT INTO Audit.PriceHistory (
    ProductID, 
    OldCostPrice, 
    NewCostPrice, 
    OldRetailPrice, 
    NewRetailPrice, 
    OldDiscountPrice, 
    NewDiscountPrice, 
    ChangedBy, 
    ChangeReason
)
SELECT TOP 30
    p.ProductID,
    p.CostPrice * 0.9, -- Old cost price (10% lower)
    p.CostPrice, -- New cost price (current)
    p.RetailPrice * 0.9, -- Old retail price (10% lower)
    p.RetailPrice, -- New retail price (current)
    NULL, -- Old discount price
    p.DiscountPrice, -- New discount price (current, may be NULL)
    (SELECT TOP 1 EmployeeID FROM HR.Employee WHERE PositionID IN (SELECT PositionID FROM HR.Position WHERE PositionTitle LIKE '%Manager%') ORDER BY NEWID()),
    'Price adjustment due to market conditions'
FROM 
    Inventory.Product p
ORDER BY 
    NEWID();

-- Generar algunos registros de historial de empleados
INSERT INTO Audit.EmployeeHistory (
    EmployeeID, 
    OldPositionID, 
    NewPositionID, 
    OldStoreID, 
    NewStoreID, 
    OldSalary, 
    NewSalary, 
    ChangedBy, 
    ChangeReason
)
SELECT TOP 20
    e.EmployeeID,
    e.PositionID, -- Current position (as new)
    e.PositionID, -- Current position (as new)
    NULL, -- Old store
    e.StoreID, -- New store (current)
    e.Salary * 0.9, -- Old salary (10% lower)
    e.Salary, -- New salary (current)
    e.ReportsTo, -- Changed by supervisor
    'Annual salary review'
FROM 
    HR.Employee e
WHERE 
    e.ReportsTo IS NOT NULL
ORDER BY 
    NEWID();

-- Generar algunos intentos de login
INSERT INTO Audit.LoginAttempt (
    UserName, 
    AttemptDate, 
    SuccessFlag, 
    IPAddress, 
    UserAgent, 
    FailReason
)
SELECT TOP 50
    CONCAT(e.FirstName, '.', e.LastName),
    DATEADD(DAY, -CAST(RAND() * 30 AS INT), GETDATE()),
    CASE WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 10 = 0 THEN 0 ELSE 1 END, -- 90% success
    CONCAT('192.168.', CAST(CAST(RAND() * 255 AS INT) AS NVARCHAR), '.', CAST(CAST(RAND() * 255 AS INT) AS NVARCHAR)),
    CASE 
        WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 3 = 0 THEN 'Chrome/91.0.4472.124'
        WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 3 = 1 THEN 'Firefox/89.0'
        ELSE 'Edge/91.0.864.59'
    END,
    CASE WHEN ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) % 10 = 0 THEN 'Invalid password' ELSE NULL END
FROM 
    HR.Employee e
ORDER BY 
    NEWID();

PRINT 'Datos generados exitosamente.';
PRINT CONCAT('Tiempo de finalización: ', CONVERT(VARCHAR, GETDATE(), 120));

-- Estadísticas finales
SELECT 'Tablas de Ubicación y Tienda' AS Categoría, '' AS Cantidad
UNION ALL
SELECT 'Países', CAST(COUNT(*) AS VARCHAR) FROM Store.Country
UNION ALL
SELECT 'Regiones', CAST(COUNT(*) AS VARCHAR) FROM Store.Region
UNION ALL
SELECT 'Ciudades', CAST(COUNT(*) AS VARCHAR) FROM Store.City
UNION ALL
SELECT 'Tipos de Tienda', CAST(COUNT(*) AS VARCHAR) FROM Store.StoreType
UNION ALL
SELECT 'Tiendas', CAST(COUNT(*) AS VARCHAR) FROM Store.Store
UNION ALL
SELECT 'Tablas de Recursos Humanos', ''
UNION ALL
SELECT 'Departamentos', CAST(COUNT(*) AS VARCHAR) FROM HR.Department
UNION ALL
SELECT 'Posiciones', CAST(COUNT(*) AS VARCHAR) FROM HR.Position
UNION ALL
SELECT 'Empleados', CAST(COUNT(*) AS VARCHAR) FROM HR.Employee
UNION ALL
SELECT 'Horarios', CAST(COUNT(*) AS VARCHAR) FROM HR.Schedule
UNION ALL
SELECT 'Tablas de Inventario', ''
UNION ALL
SELECT 'Categorías', CAST(COUNT(*) AS VARCHAR) FROM Inventory.Category
UNION ALL
SELECT 'Proveedores', CAST(COUNT(*) AS VARCHAR) FROM Inventory.Supplier
UNION ALL
SELECT 'Productos', CAST(COUNT(*) AS VARCHAR) FROM Inventory.Product
UNION ALL
SELECT 'Inventario por Tienda', CAST(COUNT(*) AS VARCHAR) FROM Inventory.StoreInventory
UNION ALL
SELECT 'Transacciones de Inventario', CAST(COUNT(*) AS VARCHAR) FROM Inventory.InventoryTransaction
UNION ALL
SELECT 'Tablas de Ventas y Clientes', ''
UNION ALL
SELECT 'Niveles de Lealtad', CAST(COUNT(*) AS VARCHAR) FROM Sales.LoyaltyLevel
UNION ALL
SELECT 'Clientes', CAST(COUNT(*) AS VARCHAR) FROM Sales.Customer
UNION ALL
SELECT 'Métodos de Pago', CAST(COUNT(*) AS VARCHAR) FROM Sales.PaymentMethod
UNION ALL
SELECT 'Promociones', CAST(COUNT(*) AS VARCHAR) FROM Sales.Promotion
UNION ALL
SELECT 'Promociones por Producto', CAST(COUNT(*) AS VARCHAR) FROM Sales.ProductPromotion
UNION ALL
SELECT 'Ventas', CAST(COUNT(*) AS VARCHAR) FROM Sales.Sale
UNION ALL
SELECT 'Detalles de Ventas', CAST(COUNT(*) AS VARCHAR) FROM Sales.SaleDetail
UNION ALL
SELECT 'Tablas de Auditoría', ''
UNION ALL
SELECT 'Cambios de Esquema', CAST(COUNT(*) AS VARCHAR) FROM Audit.SchemaChanges
UNION ALL
SELECT 'Historial de Precios', CAST(COUNT(*) AS VARCHAR) FROM Audit.PriceHistory
UNION ALL
SELECT 'Historial de Empleados', CAST(COUNT(*) AS VARCHAR) FROM Audit.EmployeeHistory
UNION ALL
SELECT 'Intentos de Acceso', CAST(COUNT(*) AS VARCHAR) FROM Audit.LoginAttempt;