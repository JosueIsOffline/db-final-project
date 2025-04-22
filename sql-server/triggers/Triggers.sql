
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