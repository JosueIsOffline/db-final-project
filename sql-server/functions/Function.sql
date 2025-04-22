
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

