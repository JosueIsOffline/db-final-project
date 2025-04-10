/*
    Retail Chain Management System - Master Script
    Final Project - Advanced Database
    ITLA

	----------------------------------------------------------------------
    Instrucciones de ejecución:
    ----------------------------------------------------------------------
    Este script utiliza comandos especiales del modo SQLCMD, como ':r',
    que permiten ejecutar múltiples archivos SQL en secuencia.

    Requisitos para ejecutar correctamente este script:

    1. Usar SQL Server Management Studio (SSMS) con el modo SQLCMD activado:
       - Ir al menú "Query" → "SQLCMD Mode"
       - Luego presionar "Execute" o F5 para ejecutar el script completo

       Si NO activas el modo SQLCMD, recibirás errores como:
       Msg 102, Level 15, State 1, Line X - Incorrect syntax near ':'

    2. Alternativamente, puedes ejecutarlo desde la línea de comandos:
       sqlcmd -S <NombreServidor> -E -i .\sql-server\schema\00_MasterScript.sql

       Ejemplo:
       sqlcmd -S localhost -E -i C:\Scripts\MasterScript.sql

    ----------------------------------------------------------------------
    Estructura del script:

    :r .\sql-server\schema\01_Database_Create.sql              -- Crea la base de datos
    :r .\sql-server\schema\02_Store_Location_Tables.sql     -- Tablas de ubicación y tiendas
    :r .\sql-server\schema\03_HR_Tables.sql                   -- Tablas de Recursos Humanos
    :r .\sql-server\schema\04_Inventory_Tables.sql          -- Tablas de inventario y productos
    :r .\sql-server\schema\05_Sales_Customer_Tables.sql       -- Tablas de ventas y clientes
    :r .\sql-server\schema\06_Audit_Tables.sql               -- Tablas de auditoría y logs
	:r .\sql-server\schema\07_Relationships.sql               -- Relaciones con  dependencias circulares

    ----------------------------------------------------------------------
*/

-- This script executes all the database creation scripts in the correct order

:r .\sql-server\schema\01_Database_Create.sql
:r .\sql-server\schema\02_Store_Location_Tables.sql
:r .\sql-server\schema\03_HR_Tables.sql
:r .\sql-server\schema\04_Inventory_Tables.sql
:r .\sql-server\schema\05_Sales_Customer_Tables.sql
:r .\sql-server\schema\06_Audit_Tables.sql
:r .\sql-server\schema\07_Relationships.sql
:r .\sql-server\schema\08_Indexes.sql