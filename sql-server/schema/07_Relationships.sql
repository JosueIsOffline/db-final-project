/*
    Retail Chain Management System - Circular References & Relationships
    Final Project - Advanced Database
    ITLA

	This file resolves circular dependencies in the schema.
    
    The Store.Store table has a ManagerID field that references HR.Employee,
    while HR.Employee has a StoreID field that references Store.Store.
    
    To resolve this dependency cycle:
    1. First we create Store.Store without the ManagerID FK
    2. Then we create HR.Employee with its FK to Store.Store
    3. Finally, in this script, we add the FK from Store.Store to HR.Employee
    
    This separation allows us to load the tables in the correct order without
    circular dependency errors.
*/

USE RetailChainDB;
GO

-- Update Store table with ManagerID foreign key
-- This must be done after the Employee table is created due to circular reference
ALTER TABLE Store.Store
ADD CONSTRAINT FK_Store_Manager FOREIGN KEY (ManagerID) REFERENCES HR.Employee(EmployeeID);

PRINT 'Additional relationships created successfully!';
GO