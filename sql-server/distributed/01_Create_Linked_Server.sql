/*
    Retail Chain Management System - Linked Server Configuration
    Final Project - Advanced Database
    ITLA

	This script creates a linked server named 'LOCAL' that connects
    the current SQL Server instance to a remote server named 'DESKTOP-2JU6T45', 
    where the database RetailChainDB is hosted.

    Purpose:
    - Enable distributed queries across servers
    - Facilitate modular architecture for Inventory, 
      HR, Sales, and other schemas
*/

USE master
GO

DECLARE @CurrentServerName NVARCHAR(128)
DECLARE @SQL NVARCHAR(1000)

SELECT @CurrentServerName = @@SERVERNAME

SET @SQL = N'
EXEC sp_addlinkedserver 
    @server = ''LOCAL'', 
    @srvproduct = '''',
    @provider = ''SQLNCLI11'',
    @datasrc = ''' + @CurrentServerName + ''';'

EXECUTE sp_executesql @SQL


PRINT 'Linked Server LOCAL created successfully with datasrc = ' + @CurrentServerName;
GO




