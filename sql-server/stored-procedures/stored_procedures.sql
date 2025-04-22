

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



