/*
    Retail Chain Management System - Sales and Customer Tables
    Final Project - Advanced Database
    ITLA
*/

USE RetailChainDB;
GO

-- ========================
-- CUSTOMER TABLES
-- ========================

-- Customer loyalty program levels
CREATE TABLE Sales.LoyaltyLevel (
    LevelID INT IDENTITY(1,1) PRIMARY KEY,
    LevelName NVARCHAR(50) NOT NULL UNIQUE,
    MinimumPoints INT NOT NULL,
    DiscountPercentage DECIMAL(5, 2) NOT NULL,
    OtherBenefits NVARCHAR(255) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL
);

-- Customers
CREATE TABLE Sales.Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NULL UNIQUE,
    Phone NVARCHAR(20) NULL,
    Address NVARCHAR(255) NULL,
    CityID INT NULL,
    LoyaltyCardNumber NVARCHAR(50) NULL UNIQUE,
    LoyaltyPoints INT NOT NULL DEFAULT 0,
    LoyaltyLevelID INT NULL,
    BirthDate DATE NULL,
    Gender CHAR(1) NULL CHECK (Gender IN ('M', 'F', 'O')),
    IsActive BIT NOT NULL DEFAULT 1,
    JoinDate DATE NOT NULL DEFAULT GETDATE(),
    LastPurchaseDate DATE NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    CONSTRAINT FK_Customer_City FOREIGN KEY (CityID) REFERENCES Store.City(CityID),
    CONSTRAINT FK_Customer_LoyaltyLevel FOREIGN KEY (LoyaltyLevelID) REFERENCES Sales.LoyaltyLevel(LevelID)
);

-- ========================
-- SALES TABLES
-- ========================

-- Payment methods
CREATE TABLE Sales.PaymentMethod (
    PaymentMethodID INT IDENTITY(1,1) PRIMARY KEY,
    MethodName NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(255) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL
);

-- Promotions and discounts
CREATE TABLE Sales.Promotion (
    PromotionID INT IDENTITY(1,1) PRIMARY KEY,
    PromotionName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255) NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    DiscountType NVARCHAR(20) NOT NULL CHECK (DiscountType IN ('Percentage', 'FixedAmount', 'BuyXGetY')),
    DiscountValue DECIMAL(10, 2) NOT NULL,
    MinimumPurchase DECIMAL(10, 2) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    CONSTRAINT CHK_Promotion_Dates CHECK (EndDate >= StartDate)
);

-- Product promotions (Many-to-Many)
CREATE TABLE Sales.ProductPromotion (
    ProductPromotionID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    PromotionID INT NOT NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    CONSTRAINT FK_ProductPromotion_Product FOREIGN KEY (ProductID) REFERENCES Inventory.Product(ProductID),
    CONSTRAINT FK_ProductPromotion_Promotion FOREIGN KEY (PromotionID) REFERENCES Sales.Promotion(PromotionID),
    CONSTRAINT UQ_Product_Promotion UNIQUE (ProductID, PromotionID)
);

-- Sales/Orders header
CREATE TABLE Sales.Sale (
    SaleID INT IDENTITY(1,1) PRIMARY KEY,
    SaleNumber NVARCHAR(50) NOT NULL UNIQUE,
    StoreID INT NOT NULL,
    CustomerID INT NULL, -- NULL for anonymous customers
    EmployeeID INT NOT NULL, -- Cashier
    SaleDate DATETIME NOT NULL DEFAULT GETDATE(),
    SubTotal DECIMAL(10, 2) NOT NULL,
    TaxAmount DECIMAL(10, 2) NOT NULL,
    DiscountAmount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    PaymentMethodID INT NOT NULL,
    PaymentReference NVARCHAR(100) NULL, -- Card/check/transaction reference
    LoyaltyPointsEarned INT NULL,
    PromotionID INT NULL,
    Notes NVARCHAR(255) NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Completed' CHECK (Status IN ('Completed', 'Returned', 'Cancelled')),
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    CONSTRAINT FK_Sale_Store FOREIGN KEY (StoreID) REFERENCES Store.Store(StoreID),
    CONSTRAINT FK_Sale_Customer FOREIGN KEY (CustomerID) REFERENCES Sales.Customer(CustomerID),
    CONSTRAINT FK_Sale_Employee FOREIGN KEY (EmployeeID) REFERENCES HR.Employee(EmployeeID),
    CONSTRAINT FK_Sale_PaymentMethod FOREIGN KEY (PaymentMethodID) REFERENCES Sales.PaymentMethod(PaymentMethodID),
    CONSTRAINT FK_Sale_Promotion FOREIGN KEY (PromotionID) REFERENCES Sales.Promotion(PromotionID)
);

-- Sales/Orders detail (Line items)
CREATE TABLE Sales.SaleDetail (
    SaleDetailID INT IDENTITY(1,1) PRIMARY KEY,
    SaleID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    UnitCost DECIMAL(10, 2) NOT NULL,
    Discount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    TaxRate DECIMAL(5, 2) NOT NULL DEFAULT 0,
    TaxAmount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    LineTotal DECIMAL(10, 2) NOT NULL,
    ReturnedQuantity INT NOT NULL DEFAULT 0,
    ReturnReason NVARCHAR(255) NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    CONSTRAINT FK_SaleDetail_Sale FOREIGN KEY (SaleID) REFERENCES Sales.Sale(SaleID),
    CONSTRAINT FK_SaleDetail_Product FOREIGN KEY (ProductID) REFERENCES Inventory.Product(ProductID),
    CONSTRAINT CHK_SaleDetail_Quantity CHECK (Quantity > 0),
    CONSTRAINT CHK_SaleDetail_ReturnedQuantity CHECK (ReturnedQuantity <= Quantity)
);

PRINT 'Sales and Customer tables created successfully!';
GO