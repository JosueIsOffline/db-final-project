/*
    Retail Chain Management System - Inventory Tables
    Final Project - Advanced Database
    ITLA
*/

USE RetailChainDB;
GO

-- ========================
-- PRODUCT TABLES
-- ========================

-- Product categories
CREATE TABLE Inventory.Category (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL,
    ParentCategoryID INT NULL, -- Self-referencing for hierarchical categories
    Description NVARCHAR(255) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    CONSTRAINT FK_Category_ParentCategory FOREIGN KEY (ParentCategoryID) REFERENCES Inventory.Category(CategoryID)
);

-- Manufacturers/Suppliers
CREATE TABLE Inventory.Supplier (
    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName NVARCHAR(100) NOT NULL,
    ContactName NVARCHAR(100) NULL,
    ContactEmail NVARCHAR(100) NULL,
    ContactPhone NVARCHAR(20) NULL,
    Address NVARCHAR(255) NULL,
    CityID INT NULL,
    TaxID NVARCHAR(50) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    CONSTRAINT FK_Supplier_City FOREIGN KEY (CityID) REFERENCES Store.City(CityID)
);

-- Products
CREATE TABLE Inventory.Product (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    ProductCode NVARCHAR(50) NOT NULL UNIQUE,
    SKU NVARCHAR(50) NOT NULL UNIQUE,
    Barcode NVARCHAR(50) NULL UNIQUE,
    Description NVARCHAR(MAX) NULL,
    CategoryID INT NOT NULL,
    SupplierID INT NOT NULL,
    CostPrice DECIMAL(10, 2) NOT NULL,
    RetailPrice DECIMAL(10, 2) NOT NULL,
    DiscountPrice DECIMAL(10, 2) NULL,
    Weight DECIMAL(8, 2) NULL,
    Dimensions NVARCHAR(50) NULL,
    IsPerishable BIT NOT NULL DEFAULT 0,
    MinStockLevel INT NOT NULL DEFAULT 10,
    MaxStockLevel INT NULL,
    ReorderPoint INT NOT NULL DEFAULT 20,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryID) REFERENCES Inventory.Category(CategoryID),
    CONSTRAINT FK_Product_Supplier FOREIGN KEY (SupplierID) REFERENCES Inventory.Supplier(SupplierID),
    CONSTRAINT CHK_Product_Prices CHECK (RetailPrice > 0 AND CostPrice > 0 AND (DiscountPrice IS NULL OR DiscountPrice > 0))
);

-- Store inventory (Stock levels per store)
CREATE TABLE Inventory.StoreInventory (
    InventoryID INT IDENTITY(1,1) PRIMARY KEY,
    StoreID INT NOT NULL,
    ProductID INT NOT NULL,
    QuantityInStock INT NOT NULL DEFAULT 0,
    StockDate DATETIME NOT NULL DEFAULT GETDATE(),
    LastRestockDate DATETIME NULL,
    NextRestockDate DATETIME NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    CONSTRAINT FK_StoreInventory_Store FOREIGN KEY (StoreID) REFERENCES Store.Store(StoreID),
    CONSTRAINT FK_StoreInventory_Product FOREIGN KEY (ProductID) REFERENCES Inventory.Product(ProductID),
    CONSTRAINT UQ_Store_Product UNIQUE (StoreID, ProductID)
);

-- Inventory transactions (All stock movements)
CREATE TABLE Inventory.InventoryTransaction (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    StoreID INT NOT NULL,
    ProductID INT NOT NULL,
    TransactionType NVARCHAR(50) NOT NULL CHECK (TransactionType IN ('Purchase', 'Sale', 'Return', 'Transfer', 'Adjustment', 'Loss')),
    Quantity INT NOT NULL,
    TransactionDate DATETIME NOT NULL DEFAULT GETDATE(),
    SourceStoreID INT NULL, -- For transfer types
    EmployeeID INT NOT NULL,
    PurchaseOrderID INT NULL,
    SaleID INT NULL,
    Notes NVARCHAR(255) NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    CONSTRAINT FK_InventoryTransaction_Store FOREIGN KEY (StoreID) REFERENCES Store.Store(StoreID),
    CONSTRAINT FK_InventoryTransaction_Product FOREIGN KEY (ProductID) REFERENCES Inventory.Product(ProductID),
    CONSTRAINT FK_InventoryTransaction_SourceStore FOREIGN KEY (SourceStoreID) REFERENCES Store.Store(StoreID),
    CONSTRAINT FK_InventoryTransaction_Employee FOREIGN KEY (EmployeeID) REFERENCES HR.Employee(EmployeeID)
);

PRINT 'Inventory tables created successfully!';
GO