/*
    Retail Chain Management System - Indexes
    Final Project - Advanced Database
    ITLA
*/

USE RetailChainDB;
GO

-- ========================
-- INDEXES
-- ========================

-- Store indexes
CREATE NONCLUSTERED INDEX IX_Store_StoreType ON Store.Store(StoreTypeID);
CREATE NONCLUSTERED INDEX IX_Store_City ON Store.Store(CityID);
CREATE NONCLUSTERED INDEX IX_Store_Manager ON Store.Store(ManagerID);

-- Employee indexes
CREATE NONCLUSTERED INDEX IX_Employee_Name ON HR.Employee(LastName, FirstName);
CREATE NONCLUSTERED INDEX IX_Employee_Position ON HR.Employee(PositionID);
CREATE NONCLUSTERED INDEX IX_Employee_Store ON HR.Employee(StoreID);
CREATE NONCLUSTERED INDEX IX_Employee_Manager ON HR.Employee(ReportsTo);

-- Product indexes
CREATE NONCLUSTERED INDEX IX_Product_Name ON Inventory.Product(ProductName);
CREATE NONCLUSTERED INDEX IX_Product_Category ON Inventory.Product(CategoryID);
CREATE NONCLUSTERED INDEX IX_Product_Supplier ON Inventory.Product(SupplierID);
CREATE NONCLUSTERED INDEX IX_Product_Barcode ON Inventory.Product(Barcode);

-- Inventory indexes
CREATE NONCLUSTERED INDEX IX_StoreInventory_Product ON Inventory.StoreInventory(ProductID);
CREATE NONCLUSTERED INDEX IX_StoreInventory_Store ON Inventory.StoreInventory(StoreID);
CREATE NONCLUSTERED INDEX IX_InventoryTransaction_Store ON Inventory.InventoryTransaction(StoreID);
CREATE NONCLUSTERED INDEX IX_InventoryTransaction_Product ON Inventory.InventoryTransaction(ProductID);
CREATE NONCLUSTERED INDEX IX_InventoryTransaction_Date ON Inventory.InventoryTransaction(TransactionDate);

-- Customer indexes
CREATE NONCLUSTERED INDEX IX_Customer_Name ON Sales.Customer(LastName, FirstName);
CREATE NONCLUSTERED INDEX IX_Customer_Email ON Sales.Customer(Email);
CREATE NONCLUSTERED INDEX IX_Customer_LoyaltyCard ON Sales.Customer(LoyaltyCardNumber);
CREATE NONCLUSTERED INDEX IX_Customer_LoyaltyLevel ON Sales.Customer(LoyaltyLevelID);

-- Sale indexes
CREATE NONCLUSTERED INDEX IX_Sale_Date ON Sales.Sale(SaleDate);
CREATE NONCLUSTERED INDEX IX_Sale_Customer ON Sales.Sale(CustomerID);
CREATE NONCLUSTERED INDEX IX_Sale_Employee ON Sales.Sale(EmployeeID);
CREATE NONCLUSTERED INDEX IX_Sale_Store ON Sales.Sale(StoreID);
CREATE NONCLUSTERED INDEX IX_Sale_Status ON Sales.Sale(Status);

-- Sale detail indexes
CREATE NONCLUSTERED INDEX IX_SaleDetail_Product ON Sales.SaleDetail(ProductID);
CREATE NONCLUSTERED INDEX IX_SaleDetail_Sale ON Sales.SaleDetail(SaleID);

-- Audit indexes
CREATE NONCLUSTERED INDEX IX_PriceHistory_Product ON Audit.PriceHistory(ProductID);
CREATE NONCLUSTERED INDEX IX_PriceHistory_Date ON Audit.PriceHistory(ChangeDate);
CREATE NONCLUSTERED INDEX IX_EmployeeHistory_Employee ON Audit.EmployeeHistory(EmployeeID);
CREATE NONCLUSTERED INDEX IX_LoginAttempt_User ON Audit.LoginAttempt(UserName);
CREATE NONCLUSTERED INDEX IX_LoginAttempt_Date ON Audit.LoginAttempt(AttemptDate);

PRINT 'Indexes created successfully!';
GO