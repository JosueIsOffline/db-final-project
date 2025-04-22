/*
    Retail Chain Management System - Distributed Query Architecture
    Final Project - Advanced Database
    ITLA

    Este script documenta una arquitectura de base de datos distribuida en la que 
    se consulta RetailChainDB mediante un Linked Server denominado "LOCAL".

    El Linked Server "LOCAL" apunta a la instancia "DESKTOP-2JU6T45", que aloja la 
    base de datos RetailChainDB. Según la implementación, puede referirse a un servidor 
    remoto o a la instancia local de SQL Server.

    La consulta distribuida a continuación recupera las transacciones de venta filtradas 
    por región (CityID = 2), integrando datos de las tablas Sales.Sale y Store.Store.

    Esta configuración demuestra cómo las consultas distribuidas pueden operar a través 
    de los límites de los servidores o dentro de la misma instancia para facilitar la 
    escalabilidad, la modularidad y la partición horizontal de datos por región.

    Tablas involucradas:
    - Sales.Sale
    - Store.Store
*/

-- Consulta de ventas por region
    SELECT 
        S.SaleID,
        S.SaleDate,
        S.TotalAmount,
        ST.StoreName,
        ST.CityID
    FROM LOCAL.RetailChainDB.Sales.Sale AS S
    JOIN LOCAL.RetailChainDB.Store.Store AS ST
        ON S.StoreID = ST.StoreID
    WHERE ST.CityID = 2;

    PRINT 'Distributed query for regional sales executed successfully.';
    GO
