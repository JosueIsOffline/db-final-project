/*
    Retail Chain Management System - Database Creation
    Final Project - Advanced Database
    ITLA
*/

USE master;
GO

-- Drop database if it exists
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'RetailChainDB')
BEGIN
    ALTER DATABASE RetailChainDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RetailChainDB;
END
GO

-- Create database
CREATE DATABASE RetailChainDB;
GO

USE RetailChainDB;
GO

-- Create schema for different areas
CREATE SCHEMA Store;
GO
CREATE SCHEMA HR;
GO
CREATE SCHEMA Sales;
GO
CREATE SCHEMA Inventory;
GO
CREATE SCHEMA Audit;
GO

PRINT 'Database and schemas created successfully!';
GO

