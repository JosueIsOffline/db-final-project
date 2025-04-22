-- ========================================
-- Phase 5: Stored Procedures, Functions, and Triggers for RetailChainDB
-- ========================================

-- =========================
-- STORED PROCEDURES
-- =========================

-- 1. Add New Employee
CREATE PROCEDURE HR.AddNewEmployee
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @Email NVARCHAR(100),
    @Phone NVARCHAR(25),
    @HireDate DATE,
    @StoreID INT,
    @PositionID INT
AS
BEGIN
    INSERT INTO HR.Employee (FirstName, LastName, Email, Phone, HireDate, StoreID, PositionID)
    VALUES (@FirstName, @LastName, @Email, @Phone, @HireDate, @StoreID, @PositionID);
END;
GO

-- 2. Register Sale
CREATE PROCEDURE Sales.RegisterSale
    @CustomerID INT,
    @EmployeeID INT,
    @StoreID INT,
    @ProductDetails Sales.SaleItemType READONLY
AS
BEGIN
    DECLARE @SaleID INT;

    INSERT INTO Sales.Sale (CustomerID, EmployeeID, StoreID, SaleDate)
    VALUES (@CustomerID, @EmployeeID, @StoreID, GETDATE());

    SET @SaleID = SCOPE_IDENTITY();

    INSERT INTO Sales.SaleDetail (SaleID, ProductID, Quantity, UnitPrice)
    SELECT @SaleID, ProductID, Quantity, UnitPrice FROM @ProductDetails;

    UPDATE Inventory.Product
    SET Stock = Stock - pd.Quantity
    FROM Inventory.Product p
    JOIN @ProductDetails pd ON p.ProductID = pd.ProductID
    WHERE p.Stock >= pd.Quantity;
END;
GO

-- 3. Transfer Product Between Stores
CREATE PROCEDURE Inventory.TransferProductBetweenStores
    @ProductID INT,
    @FromStoreID INT,
    @ToStoreID INT,
    @Quantity INT
AS
BEGIN
    BEGIN TRANSACTION;

    UPDATE Inventory.StoreProduct
    SET Stock = Stock - @Quantity
    WHERE ProductID = @ProductID AND StoreID = @FromStoreID AND Stock >= @Quantity;

    IF @@ROWCOUNT = 0
    BEGIN
        ROLLBACK;
        RAISERROR('Not enough stock to transfer.', 16, 1);
        RETURN;
    END

    MERGE Inventory.StoreProduct AS target
    USING (SELECT @ProductID AS ProductID, @ToStoreID AS StoreID) AS source
    ON target.ProductID = source.ProductID AND target.StoreID = source.StoreID
    WHEN MATCHED THEN
        UPDATE SET Stock = target.Stock + @Quantity
    WHEN NOT MATCHED THEN
        INSERT (ProductID, StoreID, Stock)
        VALUES (@ProductID, @ToStoreID, @Quantity);

    COMMIT;
END;
GO

-- =========================
-- FUNCTIONS
-- =========================

-- 1. Scalar Function: Get Total Sales by Store
CREATE FUNCTION Sales.GetTotalSalesByStore(@StoreID INT)
RETURNS MONEY
AS
BEGIN
    DECLARE @Total MONEY;

    SELECT @Total = SUM(sd.Quantity * sd.UnitPrice)
    FROM Sales.Sale s
    JOIN Sales.SaleDetail sd ON s.SaleID = sd.SaleID
    WHERE s.StoreID = @StoreID;

    RETURN ISNULL(@Total, 0);
END;
GO

-- 2. Table-Valued Function: Get Employee Sales
CREATE FUNCTION Sales.GetEmployeeSales(@EmployeeID INT)
RETURNS TABLE
AS
RETURN
    SELECT s.SaleID, s.SaleDate, sd.ProductID, sd.Quantity, sd.UnitPrice,
           (sd.Quantity * sd.UnitPrice) AS Total
    FROM Sales.Sale s
    JOIN Sales.SaleDetail sd ON s.SaleID = sd.SaleID
    WHERE s.EmployeeID = @EmployeeID;
GO

-- =========================
-- TRIGGERS
-- =========================

-- 1. Audit Trigger for Product Updates
CREATE TRIGGER Inventory.trg_Audit_ProductUpdate
ON Inventory.Product
AFTER UPDATE
AS
BEGIN
    INSERT INTO Audit.ProductChanges (ProductID, OldName, NewName, ChangeDate)
    SELECT d.ProductID, d.ProductName, i.ProductName, GETDATE()
    FROM deleted d
    JOIN inserted i ON d.ProductID = i.ProductID
    WHERE d.ProductName <> i.ProductName;
END;
GO

-- 2. Validation Trigger for Non-negative Stock
CREATE TRIGGER Inventory.trg_Check_Stock_Not_Negative
ON Inventory.StoreProduct
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM inserted WHERE Stock < 0
    )
    BEGIN
        RAISERROR('Stock cannot be negative.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        MERGE Inventory.StoreProduct AS target
        USING inserted AS source
        ON target.ProductID = source.ProductID AND target.StoreID = source.StoreID
        WHEN MATCHED THEN
            UPDATE SET Stock = source.Stock
        WHEN NOT MATCHED THEN
            INSERT (ProductID, StoreID, Stock)
            VALUES (source.ProductID, source.StoreID, source.Stock);
    END
END;
GO

-- ========================
-- Cascade triggers
-- ========================
CREATE TRIGGER trg_UpdateCountry
ON Store.Country
AFTER UPDATE
AS
BEGIN
    DECLARE @CountryID INT, @CountryName NVARCHAR(100);
    
    -- Get the old and new values of the updated record
    SELECT @CountryID = CountryID, @CountryName = CountryName
    FROM inserted;

    -- Update the Region table based on the Country update
    UPDATE Store.Region
    SET RegionName = @CountryName  -- Assuming you want to update the region name with the country's name
    WHERE CountryID = @CountryID;
    
    -- Other actions as needed
END;
