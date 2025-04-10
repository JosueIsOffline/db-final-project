/*
    Retail Chain Management System - Store and Location Tables
    Final Project - Advanced Database
    ITLA
*/

USE RetailChainDB;
GO

-- ========================
-- LOCATION TABLES
-- ========================

-- Countries table
CREATE TABLE Store.Country (
    CountryID INT IDENTITY(1,1) PRIMARY KEY,
    CountryName NVARCHAR(100) NOT NULL,
    CountryCode CHAR(2) NOT NULL UNIQUE,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL
);

-- Regions/States table
CREATE TABLE Store.Region (
    RegionID INT IDENTITY(1,1) PRIMARY KEY,
    RegionName NVARCHAR(100) NOT NULL,
    CountryID INT NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    CONSTRAINT FK_Region_Country FOREIGN KEY (CountryID) REFERENCES Store.Country(CountryID)
);

-- Cities table
CREATE TABLE Store.City (
    CityID INT IDENTITY(1,1) PRIMARY KEY,
    CityName NVARCHAR(100) NOT NULL,
    RegionID INT NOT NULL,
    PostalCode NVARCHAR(20) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    CONSTRAINT FK_City_Region FOREIGN KEY (RegionID) REFERENCES Store.Region(RegionID)
);

-- ========================
-- STORE TABLES
-- ========================

-- Store types (Mall, Street, Outlet, etc.)
CREATE TABLE Store.StoreType (
    StoreTypeID INT IDENTITY(1,1) PRIMARY KEY,
    TypeName NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(255) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL
);

-- Stores table
CREATE TABLE Store.Store (
    StoreID INT IDENTITY(1,1) PRIMARY KEY,
    StoreName NVARCHAR(100) NOT NULL,
    StoreCode NVARCHAR(20) NOT NULL UNIQUE,
    StoreTypeID INT NOT NULL,
    Address NVARCHAR(255) NOT NULL,
    CityID INT NOT NULL,
    Phone NVARCHAR(20) NULL,
    Email NVARCHAR(100) NULL,
    ManagerID INT NULL, -- Will be populated after HR.Employee is created
    OpeningDate DATE NOT NULL,
    ClosingDate DATE NULL,
    Size DECIMAL(10, 2) NULL, -- In square meters
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    CONSTRAINT FK_Store_StoreType FOREIGN KEY (StoreTypeID) REFERENCES Store.StoreType(StoreTypeID),
    CONSTRAINT FK_Store_City FOREIGN KEY (CityID) REFERENCES Store.City(CityID)
);

PRINT 'Store and Location tables created successfully!';
GO