/*
    Retail Chain Management System - Audit Tables
    Final Project - Advanced Database
    ITLA
*/

USE RetailChainDB;
GO

-- ========================
-- AUDIT TABLES
-- ========================

-- Audit logs for schema changes
CREATE TABLE Audit.SchemaChanges (
    ChangeID INT IDENTITY(1,1) PRIMARY KEY,
    EventDate DATETIME NOT NULL DEFAULT GETDATE(),
    EventType NVARCHAR(100) NOT NULL,
    ObjectName NVARCHAR(128) NOT NULL,
    ObjectType NVARCHAR(50) NOT NULL,
    SQLCommand NVARCHAR(MAX) NULL,
    UserName NVARCHAR(128) NOT NULL,
    HostName NVARCHAR(128) NOT NULL
);

-- Price history
CREATE TABLE Audit.PriceHistory (
    PriceHistoryID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    OldCostPrice DECIMAL(10, 2) NULL,
    NewCostPrice DECIMAL(10, 2) NULL,
    OldRetailPrice DECIMAL(10, 2) NULL,
    NewRetailPrice DECIMAL(10, 2) NULL,
    OldDiscountPrice DECIMAL(10, 2) NULL,
    NewDiscountPrice DECIMAL(10, 2) NULL,
    ChangeDate DATETIME NOT NULL DEFAULT GETDATE(),
    ChangedBy INT NOT NULL,
    ChangeReason NVARCHAR(255) NULL,
    CONSTRAINT FK_PriceHistory_Product FOREIGN KEY (ProductID) REFERENCES Inventory.Product(ProductID),
    CONSTRAINT FK_PriceHistory_Employee FOREIGN KEY (ChangedBy) REFERENCES HR.Employee(EmployeeID)
);

-- Employee history
CREATE TABLE Audit.EmployeeHistory (
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    OldPositionID INT NULL,
    NewPositionID INT NULL,
    OldStoreID INT NULL,
    NewStoreID INT NULL,
    OldSalary DECIMAL(10, 2) NULL,
    NewSalary DECIMAL(10, 2) NULL,
    ChangeDate DATETIME NOT NULL DEFAULT GETDATE(),
    ChangedBy INT NOT NULL,
    ChangeReason NVARCHAR(255) NULL,
    CONSTRAINT FK_EmployeeHistory_Employee FOREIGN KEY (EmployeeID) REFERENCES HR.Employee(EmployeeID),
    CONSTRAINT FK_EmployeeHistory_ChangedBy FOREIGN KEY (ChangedBy) REFERENCES HR.Employee(EmployeeID)
);

-- Login attempts
CREATE TABLE Audit.LoginAttempt (
    LoginAttemptID INT IDENTITY(1,1) PRIMARY KEY,
    UserName NVARCHAR(100) NOT NULL,
    AttemptDate DATETIME NOT NULL DEFAULT GETDATE(),
    SuccessFlag BIT NOT NULL,
    IPAddress NVARCHAR(50) NOT NULL,
    UserAgent NVARCHAR(255) NULL,
    FailReason NVARCHAR(255) NULL
);

PRINT 'Audit tables created successfully!';
GO