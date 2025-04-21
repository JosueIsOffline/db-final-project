/*
    Retail Chain Management System - Complex queries
    Final Project - Advanced Database
    ITLA
*/

-- ==========================================
-- CONSUTLA 1: Ventas por region con subconsultas anidadas
-- Análisis jerarquico de ventas por pais, region y ciudad
-- ==========================================
SELECT 
	C.CountryName,
	R.RegionName,
	CI.CityName,
	COUNT(S.SaleID) AS TotalSales,
	SUM(S.TotalAmount) AS TotalRevenue,
	AVG(S.TotalAmount) AS AverageSale,
	(
		SELECT COUNT(DISTINCT ST.StoreID)
		FROM Store.Store ST
		WHERE ST.CityID = CI.CityID
	) AS StoreCount,
	(
		SELECT TOP 1 P.ProductName
		FROM Sales.SaleDetail SD
		JOIN Inventory.Product P ON SD.ProductID = P.ProductID
		JOIN Sales.Sale S2 ON SD.SaleID = S2.SaleID
		JOIN Store.Store ST ON S2.StoreID = ST.StoreID
		WHERE ST.CityID = CI.CityID
		GROUP BY P.ProductID, P.ProductName
		ORDER BY SUM(SD.Quantity) DESC
	) AS MostSoldProduct
FROM
	Sales.Sale S
	JOIN Store.Store ST ON S.StoreID = ST.StoreID
	JOIN Store.City CI ON ST.CityID = CI.CityID
	JOIN Store.Region R ON CI.RegionID = R.RegionID
	JOIN Store.Country C ON R.CountryID = C.CountryID
WHERE 
	S.Status = 'Completed'
	AND S.SaleDate >= DATEADD(MONTH, -12, GETDATE())
GROUP BY
	C.CountryName, R.RegionName, CI.CityName, CI.CityID
HAVING
  SUM(S.TotalAmount) > 10000
ORDER BY
	C.CountryName, SUM(S.TotalAmount) DESC

-- ==========================================
-- CONSULTA 2: Rentabilidad por producto con múltiples JOIN
-- Análisis de rentabilidad que combina ventas, inventario y categorías
-- ==========================================

SELECT 
    C.CategoryName AS Category,
    P.ProductName,
    P.SKU,
    SR.SupplierName AS Supplier,
    SUM(SD.Quantity) AS TotalUnitsSold,
    SUM(SD.LineTotal) AS TotalRevenue,
    SUM(SD.Quantity * SD.UnitCost) AS TotalCost,
    SUM(SD.LineTotal) - SUM(SD.Quantity * SD.UnitCost) AS GrossProfit,
    (SUM(SD.LineTotal) - SUM(SD.Quantity * SD.UnitCost)) / NULLIF(SUM(SD.LineTotal), 0) * 100 AS ProfitMarginPercentage,
    (
        SELECT AVG(SI.QuantityInStock)
        FROM Inventory.StoreInventory SI
        WHERE SI.ProductID = P.ProductID
    ) AS AvgStockLevel
FROM 
    Sales.SaleDetail SD
    INNER JOIN Sales.Sale S ON SD.SaleID = S.SaleID
    INNER JOIN Inventory.Product P ON SD.ProductID = P.ProductID
    INNER JOIN Inventory.Category C ON P.CategoryID = C.CategoryID
    LEFT JOIN Inventory.Supplier SR ON P.SupplierID = SR.SupplierID
WHERE 
    S.Status = 'Completed'
    AND S.SaleDate >= DATEADD(MONTH, -6, GETDATE())
GROUP BY 
    C.CategoryName, P.ProductName, P.SKU, SR.SupplierName, P.ProductID
HAVING 
    SUM(SD.Quantity) > 10
ORDER BY 
    GrossProfit DESC;

-- ==========================================
-- CONSULTA 3: Jerarquía de empleados con CTE recursiva
-- Visualización jerárquica completa de la estructura organizacional
-- ==========================================

WITH EmployeeHierarchy AS (
    -- Base case: top managers (employees without managers or reporting to CEO)
    SELECT 
        E.EmployeeID,
        E.FirstName,
        E.LastName,
        E.PositionID,
        P.PositionTitle,
        D.DepartmentName,
        E.StoreID,
		E.Salary,
        0 AS HierarchyLevel,
        CAST(E.LastName + ', ' + E.FirstName AS NVARCHAR(500)) AS HierarchyPath
    FROM 
        HR.Employee E
        JOIN HR.Position P ON E.PositionID = P.PositionID
        JOIN HR.Department D ON P.DepartmentID = D.DepartmentID
        LEFT JOIN Store.Store S ON E.StoreID = S.StoreID
    WHERE 
        E.ReportsTo IS NULL
    
    UNION ALL
    
    -- Recursive case: employees reporting to managers in the hierarchy
    SELECT 
        E.EmployeeID,
        E.FirstName,
        E.LastName,
        E.PositionID,
        P.PositionTitle,
        D.DepartmentName,
        E.StoreID,
		E.Salary,
        H.HierarchyLevel + 1,
        CAST(H.HierarchyPath + ' > ' + E.LastName + ', ' + E.FirstName AS NVARCHAR(500)) AS HierarchyPath
    FROM 
        HR.Employee E
        JOIN HR.Position P ON E.PositionID = P.PositionID
        JOIN HR.Department D ON P.DepartmentID = D.DepartmentID
        JOIN EmployeeHierarchy H ON E.ReportsTo = H.EmployeeID
    -- Quitamos el LEFT JOIN aquí
)
SELECT 
    H.EmployeeID,
    H.FirstName,
    H.LastName,
    H.PositionTitle,
    H.DepartmentName,
    ISNULL(S.StoreName, 'Sin Tienda') AS StoreName, 
    H.Salary,
    H.HierarchyLevel,
    H.HierarchyPath,
    (
        SELECT COUNT(*)
        FROM HR.Employee E
        WHERE E.ReportsTo = H.EmployeeID
    ) AS DirectReports,
    (
        SELECT AVG(E.Salary)
        FROM HR.Employee E
        WHERE E.ReportsTo = H.EmployeeID
    ) AS AvgTeamSalary
FROM 
    EmployeeHierarchy H
    LEFT JOIN Store.Store S ON H.StoreID = S.StoreID 
ORDER BY 
    H.HierarchyPath;

-- ==========================================
-- CONSULTA 4: Análisis de categorías de productos con jerarquía usando CTE recursiva
-- Visualización jerárquica de categorías y subcategorías con datos de ventas
-- ==========================================

WITH CategoryHierarchy AS (
    -- Base case: top-level categories
    SELECT 
        C.CategoryID,
        C.CategoryName,
        C.ParentCategoryID,
        C.Description,
        0 AS Level,
        CAST(C.CategoryName AS NVARCHAR(500)) AS CategoryPath
    FROM 
        Inventory.Category C
    WHERE 
        C.ParentCategoryID IS NULL
    
    UNION ALL
    
    -- Recursive case: subcategories
    SELECT 
        C.CategoryID,
        C.CategoryName,
        C.ParentCategoryID,
        C.Description,
        CH.Level + 1,
        CAST(CH.CategoryPath + ' > ' + C.CategoryName AS NVARCHAR(500)) AS CategoryPath
    FROM 
        Inventory.Category C
        JOIN CategoryHierarchy CH ON C.ParentCategoryID = CH.CategoryID
)
SELECT 
    CH.CategoryID,
    CH.CategoryName,
    CH.ParentCategoryID,
    CH.Level,
    CH.CategoryPath,
    (
        SELECT COUNT(P.ProductID)
        FROM Inventory.Product P
        WHERE P.CategoryID = CH.CategoryID
    ) AS ProductCount,
    (
        SELECT SUM(SD.Quantity)
        FROM Sales.SaleDetail SD
        JOIN Inventory.Product P ON SD.ProductID = P.ProductID
        JOIN Sales.Sale S ON SD.SaleID = S.SaleID
        WHERE P.CategoryID = CH.CategoryID
        AND S.Status = 'Completed'
        AND S.SaleDate >= DATEADD(MONTH, -12, GETDATE())
    ) AS UnitsSold,
    (
        SELECT SUM(SD.LineTotal)
        FROM Sales.SaleDetail SD
        JOIN Inventory.Product P ON SD.ProductID = P.ProductID
        JOIN Sales.Sale S ON SD.SaleID = S.SaleID
        WHERE P.CategoryID = CH.CategoryID
        AND S.Status = 'Completed'
        AND S.SaleDate >= DATEADD(MONTH, -12, GETDATE())
    ) AS TotalRevenue
FROM 
    CategoryHierarchy CH
ORDER BY 
    CH.CategoryPath;

-- ==========================================
-- CONSULTA 5: Análisis de clientes y programa de fidelidad con múltiple filtrado
-- Análisis completo del comportamiento de clientes y efectividad del programa de lealtad
-- ==========================================

SELECT 
    C.CustomerID,
    C.FirstName + ' ' + C.LastName AS CustomerName,
    C.Email,
    CT.CityName,
    R.RegionName,
    CO.CountryName,
    LL.LevelName AS LoyaltyLevel,
    C.LoyaltyPoints,
    COUNT(S.SaleID) AS TotalPurchases,
    SUM(S.TotalAmount) AS TotalSpent,
    AVG(S.TotalAmount) AS AveragePurchase,
    MAX(S.SaleDate) AS LastPurchaseDate,
    DATEDIFF(DAY, MAX(S.SaleDate), GETDATE()) AS DaysSinceLastPurchase,
    (
        SELECT TOP 1 P.CategoryID
        FROM Sales.SaleDetail SD
        JOIN Sales.Sale S2 ON SD.SaleID = S2.SaleID
        JOIN Inventory.Product P ON SD.ProductID = P.ProductID
        WHERE S2.CustomerID = C.CustomerID
        GROUP BY P.CategoryID
        ORDER BY SUM(SD.Quantity) DESC
    ) AS FavoriteCategoryID,
    (
        SELECT TOP 1 CAT.CategoryName
        FROM Sales.SaleDetail SD
        JOIN Sales.Sale S2 ON SD.SaleID = S2.SaleID
        JOIN Inventory.Product P ON SD.ProductID = P.ProductID
        JOIN Inventory.Category CAT ON P.CategoryID = CAT.CategoryID
        WHERE S2.CustomerID = C.CustomerID
        GROUP BY CAT.CategoryID, CAT.CategoryName
        ORDER BY SUM(SD.Quantity) DESC
    ) AS FavoriteCategory
FROM 
    Sales.Customer C
    LEFT JOIN Store.City CT ON C.CityID = CT.CityID
    LEFT JOIN Store.Region R ON CT.RegionID = R.RegionID
    LEFT JOIN Store.Country CO ON R.CountryID = CO.CountryID
    LEFT JOIN Sales.LoyaltyLevel LL ON C.LoyaltyLevelID = LL.LevelID
    LEFT JOIN Sales.Sale S ON C.CustomerID = S.CustomerID AND S.Status = 'Completed'
WHERE 
    C.IsActive = 1
    AND (C.LoyaltyPoints > 0 OR S.SaleID IS NOT NULL)
GROUP BY 
    C.CustomerID, 
    C.FirstName, 
    C.LastName, 
    C.Email, 
    CT.CityName, 
    R.RegionName, 
    CO.CountryName, 
    LL.LevelName, 
    C.LoyaltyPoints
HAVING 
    COUNT(S.SaleID) > 1
    AND DATEDIFF(MONTH, MAX(S.SaleDate), GETDATE()) <= 6
ORDER BY 
    SUM(S.TotalAmount) DESC;

-- ==========================================
-- CONSULTA 6: Rotación de inventario y análisis de reposición
-- Análisis completo del rendimiento de inventario para optimizar la reposición
-- ==========================================

WITH InventoryMovement AS (
    SELECT
        P.ProductID,
        P.ProductName,
        P.SKU,
        C.CategoryName,
        S.SupplierName,
        ST.StoreID,
        ST.StoreName,
        SI.QuantityInStock,
        P.MinStockLevel,
        P.ReorderPoint,
        P.MaxStockLevel,
        (
            SELECT SUM(SD.Quantity)
            FROM Sales.SaleDetail SD
            JOIN Sales.Sale S ON SD.SaleID = S.SaleID
            WHERE SD.ProductID = P.ProductID
            AND S.StoreID = ST.StoreID
            AND S.Status = 'Completed'
            AND S.SaleDate >= DATEADD(MONTH, -3, GETDATE())
        ) AS UnitsSold3Months,
        (
            SELECT SUM(IT.Quantity)
            FROM Inventory.InventoryTransaction IT
            WHERE IT.ProductID = P.ProductID
            AND IT.StoreID = ST.StoreID
            AND IT.TransactionType = 'Purchase'
            AND IT.TransactionDate >= DATEADD(MONTH, -3, GETDATE())
        ) AS UnitsReceived3Months,
        SI.LastRestockDate
    FROM
        Inventory.StoreInventory SI
        JOIN Inventory.Product P ON SI.ProductID = P.ProductID
        JOIN Inventory.Category C ON P.CategoryID = C.CategoryID
        JOIN Inventory.Supplier S ON P.SupplierID = S.SupplierID
        JOIN Store.Store ST ON SI.StoreID = ST.StoreID
    WHERE
        ST.IsActive = 1
        AND P.IsActive = 1
)
SELECT
    IM.ProductID,
    IM.ProductName,
    IM.SKU,
    IM.CategoryName,
    IM.SupplierName,
    IM.StoreID,
    IM.StoreName,
    IM.QuantityInStock,
    IM.UnitsSold3Months,
    IM.UnitsReceived3Months,
    IM.MinStockLevel,
    IM.ReorderPoint,
    IM.MaxStockLevel,
    CASE
        WHEN IM.QuantityInStock <= IM.MinStockLevel THEN 'Critical'
        WHEN IM.QuantityInStock <= IM.ReorderPoint THEN 'Reorder'
        WHEN IM.QuantityInStock > IM.MaxStockLevel THEN 'Overstocked'
        ELSE 'Normal'
    END AS StockStatus,
    CASE
        WHEN IM.UnitsSold3Months > 0 
        THEN (IM.UnitsSold3Months / 90.0) -- Daily average sales
        ELSE 0
    END AS DailyAverageSales,
    CASE
        WHEN IM.UnitsSold3Months > 0 
        THEN IM.QuantityInStock / (IM.UnitsSold3Months / 90.0) -- Days of stock remaining
        ELSE NULL
    END AS EstimatedDaysOfStock,
    CASE
        WHEN IM.UnitsSold3Months > 0 AND IM.UnitsSold3Months > 0
        THEN (IM.UnitsSold3Months * 1.0) / NULLIF(IM.QuantityInStock + IM.UnitsSold3Months - IM.UnitsReceived3Months, 0)
        ELSE 0
    END AS InventoryTurnoverRate,
    DATEDIFF(DAY, IM.LastRestockDate, GETDATE()) AS DaysSinceLastRestock
FROM
    InventoryMovement IM
WHERE
    (IM.QuantityInStock <= IM.ReorderPoint OR IM.UnitsSold3Months > 0)
ORDER BY
    CASE
        WHEN IM.QuantityInStock <= IM.MinStockLevel THEN 1
        WHEN IM.QuantityInStock <= IM.ReorderPoint THEN 2
        WHEN IM.QuantityInStock > IM.MaxStockLevel THEN 4
        ELSE 3
    END,
    EstimatedDaysOfStock;

-- ==========================================
-- CONSULTA 7: Rendimiento de tiendas y empleados con análisis temporal
-- Análisis comparativo del rendimiento de tiendas y su personal
-- ==========================================

WITH StoreMonthlySales AS (
    -- Calcula ventas mensuales por tienda
    SELECT
        ST.StoreID,
        ST.StoreName,
        YEAR(S.SaleDate) AS SaleYear,
        MONTH(S.SaleDate) AS SaleMonth,
        COUNT(S.SaleID) AS TotalTransactions,
        SUM(S.TotalAmount) AS TotalSales,
        COUNT(DISTINCT S.CustomerID) AS UniqueCustomers,
        SUM(S.TotalAmount) / COUNT(S.SaleID) AS AverageTicket
    FROM
        Sales.Sale S
        JOIN Store.Store ST ON S.StoreID = ST.StoreID
    WHERE
        S.Status = 'Completed'
        AND S.SaleDate >= DATEADD(YEAR, -1, GETDATE())
    GROUP BY
        ST.StoreID,
        ST.StoreName,
        YEAR(S.SaleDate),
        MONTH(S.SaleDate)
),
StoreMetrics AS (
    -- Calcula métricas agregadas por tienda
    SELECT
        StoreID,
        StoreName,
        SUM(TotalSales) AS AnnualSales,
        SUM(TotalTransactions) AS AnnualTransactions,
        AVG(TotalSales) AS AvgMonthlySales,
        MAX(TotalSales) AS BestMonthSales,
        MIN(TotalSales) AS WorstMonthSales,
        STDEV(TotalSales) AS SalesStandardDeviation,
        AVG(AverageTicket) AS AvgTicketSize,
        SUM(UniqueCustomers) AS TotalCustomersServed
    FROM
        StoreMonthlySales
    GROUP BY
        StoreID,
        StoreName
),
TopEmployees AS (
    -- Encuentra el mejor vendedor por tienda
    SELECT
        S.StoreID,
        E.EmployeeID,
        E.FirstName + ' ' + E.LastName AS EmployeeName,
        P.PositionTitle,
        COUNT(S.SaleID) AS SalesCount,
        SUM(S.TotalAmount) AS TotalSales,
        RANK() OVER (PARTITION BY S.StoreID ORDER BY SUM(S.TotalAmount) DESC) AS SalesRank
    FROM
        Sales.Sale S
        JOIN HR.Employee E ON S.EmployeeID = E.EmployeeID
        JOIN HR.Position P ON E.PositionID = P.PositionID
    WHERE
        S.Status = 'Completed'
        AND S.SaleDate >= DATEADD(YEAR, -1, GETDATE())
    GROUP BY
        S.StoreID,
        E.EmployeeID,
        E.FirstName,
        E.LastName,
        P.PositionTitle
)
SELECT
    SM.StoreID,
    SM.StoreName,
    ST.StoreCode,
    STT.TypeName AS StoreType,
    C.CityName,
    R.RegionName,
    CO.CountryName,
    (
        SELECT COUNT(*)
        FROM HR.Employee E
        WHERE E.StoreID = SM.StoreID
        AND E.IsActive = 1
    ) AS EmployeeCount,
    E.FirstName + ' ' + E.LastName AS StoreManager,
    SM.AnnualSales,
    SM.AvgMonthlySales,
    SM.BestMonthSales,
    SM.WorstMonthSales,
    SM.BestMonthSales - SM.WorstMonthSales AS SalesRange,
    SM.SalesStandardDeviation,
    SM.AnnualTransactions,
    SM.AvgTicketSize,
    SM.TotalCustomersServed,
    TE.EmployeeName AS TopSalesperson,
    TE.PositionTitle AS TopSalespersonPosition,
    TE.TotalSales AS TopSalespersonSales,
    SM.AnnualSales / SM.TotalCustomersServed AS AverageSalesPerCustomer,
    SM.AnnualSales / NULLIF((
        SELECT COUNT(*)
        FROM HR.Employee E
        WHERE E.StoreID = SM.StoreID
        AND E.IsActive = 1
    ), 0) AS SalesPerEmployee,
    RANK() OVER (ORDER BY SM.AnnualSales DESC) AS OverallSalesRank
FROM
    StoreMetrics SM
    JOIN Store.Store ST ON SM.StoreID = ST.StoreID
    JOIN Store.StoreType STT ON ST.StoreTypeID = STT.StoreTypeID
    JOIN Store.City C ON ST.CityID = C.CityID
    JOIN Store.Region R ON C.RegionID = R.RegionID
    JOIN Store.Country CO ON R.CountryID = CO.CountryID
    JOIN HR.Employee E ON ST.ManagerID = E.EmployeeID
    LEFT JOIN TopEmployees TE ON SM.StoreID = TE.StoreID AND TE.SalesRank = 1
ORDER BY
    SM.AnnualSales DESC;

-- ==========================================
-- CONSULTA 8: Análisis de impacto de promociones y eficacia
-- Evaluación detallada del impacto de cada promoción en las ventas
-- ==========================================

WITH PromotionSales AS (
    -- Ventas con promociones
    SELECT
        PR.PromotionID,
        PR.PromotionName,
        PR.StartDate,
        PR.EndDate,
        PR.DiscountType,
        PR.DiscountValue,
        S.SaleID,
        S.SaleDate,
        S.TotalAmount,
        S.DiscountAmount,
        SD.ProductID,
        P.ProductName,
        SD.Quantity,
        SD.LineTotal,
        C.CategoryID,
        C.CategoryName
    FROM
        Sales.Sale S
        JOIN Sales.SaleDetail SD ON S.SaleID = SD.SaleID
        JOIN Inventory.Product P ON SD.ProductID = P.ProductID
        JOIN Inventory.Category C ON P.CategoryID = C.CategoryID
        JOIN Sales.Promotion PR ON S.PromotionID = PR.PromotionID
    WHERE
        S.Status = 'Completed'
        AND S.SaleDate BETWEEN PR.StartDate AND PR.EndDate
),
ProductPromotions AS (
    -- Relación productos-promociones
    SELECT
        PP.PromotionID,
        PP.ProductID
    FROM
        Sales.ProductPromotion PP
),
PromotionMetrics AS (
    -- Métricas principales por promoción
    SELECT
        PS.PromotionID,
        PS.PromotionName,
        PS.DiscountType,
        PS.DiscountValue,
        PS.StartDate,
        PS.EndDate,
        DATEDIFF(DAY, PS.StartDate, PS.EndDate) + 1 AS PromotionDays,
        COUNT(DISTINCT PS.SaleID) AS TotalSales,
        SUM(PS.TotalAmount) AS TotalRevenue,
        SUM(PS.DiscountAmount) AS TotalDiscounts,
        SUM(PS.Quantity) AS TotalUnitsSold,
        COUNT(DISTINCT PS.ProductID) AS ProductsImpacted,
        COUNT(DISTINCT PS.CategoryID) AS CategoriesImpacted
    FROM
        PromotionSales PS
    GROUP BY
        PS.PromotionID,
        PS.PromotionName,
        PS.DiscountType,
        PS.DiscountValue,
        PS.StartDate,
        PS.EndDate
),
ControlPeriodSales AS (
    -- Ventas en periodo anterior para comparar
    SELECT
        P.PromotionID,
        COUNT(DISTINCT S.SaleID) AS ControlSales,
        SUM(S.TotalAmount) AS ControlRevenue,
        SUM(SD.Quantity) AS ControlUnitsSold
    FROM
        Sales.Sale S
        JOIN Sales.SaleDetail SD ON S.SaleID = SD.SaleID
        JOIN ProductPromotions PP ON SD.ProductID = PP.ProductID
        JOIN PromotionMetrics P ON PP.PromotionID = P.PromotionID
    WHERE
        S.Status = 'Completed'
        AND S.PromotionID IS NULL
        AND S.SaleDate BETWEEN 
            DATEADD(DAY, -P.PromotionDays, P.StartDate) 
            AND DATEADD(DAY, -1, P.StartDate)
    GROUP BY
        P.PromotionID
)
SELECT
    PM.PromotionID,
    PM.PromotionName,
    PM.DiscountType,
    PM.DiscountValue,
    PM.StartDate,
    PM.EndDate,
    PM.PromotionDays,
    PM.TotalSales,
    PM.TotalRevenue,
    PM.TotalDiscounts,
    PM.TotalUnitsSold,
    PM.ProductsImpacted,
    PM.CategoriesImpacted,
    CPS.ControlSales,
    CPS.ControlRevenue,
    CPS.ControlUnitsSold,
    PM.TotalSales - ISNULL(CPS.ControlSales, 0) AS SalesIncrease,
    PM.TotalRevenue - ISNULL(CPS.ControlRevenue, 0) AS RevenueIncrease,
    PM.TotalUnitsSold - ISNULL(CPS.ControlUnitsSold, 0) AS UnitsIncrease,
    CASE 
        WHEN ISNULL(CPS.ControlSales, 0) = 0 THEN NULL
        ELSE (PM.TotalSales - CPS.ControlSales) * 100.0 / CPS.ControlSales 
    END AS SalesIncreasePercent,
    CASE 
        WHEN ISNULL(CPS.ControlRevenue, 0) = 0 THEN NULL
        ELSE (PM.TotalRevenue - CPS.ControlRevenue) * 100.0 / CPS.ControlRevenue 
    END AS RevenueIncreasePercent,
    PM.TotalRevenue / NULLIF(PM.TotalDiscounts, 0) AS RevenueToCostRatio,
    PM.TotalSales / NULLIF(PM.PromotionDays, 0) AS SalesPerDay,
    (
        SELECT TOP 1 PS.CategoryName
        FROM PromotionSales PS
        WHERE PS.PromotionID = PM.PromotionID
        GROUP BY PS.CategoryID, PS.CategoryName
        ORDER BY SUM(PS.Quantity) DESC
    ) AS TopCategory,
    (
        SELECT TOP 1 PS.ProductName
        FROM PromotionSales PS
        WHERE PS.PromotionID = PM.PromotionID
        GROUP BY PS.ProductID, PS.ProductName
        ORDER BY SUM(PS.Quantity) DESC
    ) AS TopProduct
FROM
    PromotionMetrics PM
    LEFT JOIN ControlPeriodSales CPS ON PM.PromotionID = CPS.PromotionID
ORDER BY
    RevenueIncreasePercent DESC;