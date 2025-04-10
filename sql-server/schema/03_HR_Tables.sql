/*
    Retail Chain Management System - Human Resources Tables
    Final Project - Advanced Database
    ITLA
*/

USE RetailChainDB;
GO

-- ========================
-- HUMAN RESOURCES TABLES
-- ========================

-- Departments table
CREATE TABLE HR.Department (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(255) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL
);

-- Job positions table
CREATE TABLE HR.Position (
    PositionID INT IDENTITY(1,1) PRIMARY KEY,
    PositionTitle NVARCHAR(100) NOT NULL,
    DepartmentID INT NOT NULL,
    MinSalary DECIMAL(10, 2) NULL,
    MaxSalary DECIMAL(10, 2) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    CONSTRAINT FK_Position_Department FOREIGN KEY (DepartmentID) REFERENCES HR.Department(DepartmentID)
);

-- Employees table
CREATE TABLE HR.Employee (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    EmployeeCode NVARCHAR(20) NOT NULL UNIQUE,
    Email NVARCHAR(100) NULL UNIQUE,
    Phone NVARCHAR(20) NULL,
    HireDate DATE NOT NULL,
    TerminationDate DATE NULL,
    BirthDate DATE NOT NULL,
    Gender CHAR(1) NULL CHECK (Gender IN ('M', 'F', 'O')),
    Address NVARCHAR(255) NULL,
    CityID INT NULL,
    PositionID INT NOT NULL,
    StoreID INT NULL, -- NULL for headquarter employees
    ReportsTo INT NULL, -- Self-referencing for hierarchy
    Salary DECIMAL(10, 2) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    CONSTRAINT FK_Employee_Position FOREIGN KEY (PositionID) REFERENCES HR.Position(PositionID),
    CONSTRAINT FK_Employee_Store FOREIGN KEY (StoreID) REFERENCES Store.Store(StoreID),
    CONSTRAINT FK_Employee_City FOREIGN KEY (CityID) REFERENCES Store.City(CityID),
    CONSTRAINT FK_Employee_Manager FOREIGN KEY (ReportsTo) REFERENCES HR.Employee(EmployeeID)
);

-- Work schedule table
CREATE TABLE HR.Schedule (
    ScheduleID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    WorkDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    EndTime TIME NOT NULL,
    IsHoliday BIT NOT NULL DEFAULT 0,
    IsVacation BIT NOT NULL DEFAULT 0,
    IsSickLeave BIT NOT NULL DEFAULT 0,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME NULL,
    CONSTRAINT FK_Schedule_Employee FOREIGN KEY (EmployeeID) REFERENCES HR.Employee(EmployeeID),
    CONSTRAINT UQ_Employee_WorkDate UNIQUE (EmployeeID, WorkDate)
);

PRINT 'Human Resources tables created successfully!';
GO