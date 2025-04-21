--  COMBINED QUERY (Corrected CTE Placement - Still NOT Recommended for Production)
--  This version corrects the CTE syntax but remains complex and inefficient.

--  Declare the CTE *outside* the main query
WITH HistorialCompras AS (
    SELECT
        ClienteID,
        VentssID,
        FechaVenta,
        Monto,
        1 AS Nivel
    FROM Ventas
    WHERE ClienteID = 1  -- Cliente específico

    UNION ALL

    SELECT
        V.ClienteID,
        V.VentaID,
        V.FechaVenta,
        V.Monto,
        H.Nivel + 1
    FROM Ventas V
    INNER JOIN HistorialCompras H ON V.ClienteID = H.ClienteID
    WHERE V.FechaVenta < H.FechaVenta
)

--  Main combined query
SELECT
    'Query 1: Last Month Sales' AS QueryPurpose,
    VentaID,
    FechaVenta,
    Monto,
    ClienteID,
    NULL AS TotalVentasPorSucursal,
    NULL AS EmpleadoNombre,
    NULL AS ProductoNombre,
    NULL AS TotalUnidadesVendidas,
    NULL AS HistorialClienteID,
    NULL AS HistorialFechaVenta,
    NULL AS HistorialNivel,
    NULL AS SucursalesConProducto
FROM Ventas
WHERE FechaVenta >= DATEADD(MONTH, -1, GETDATE())

UNION ALL

SELECT
    'Query 2: Total Sales by Branch',
    NULL, NULL, NULL, NULL,
    SUM(Monto),
    NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM Ventas
GROUP BY SucursalID

UNION ALL

SELECT
    'Query 3: Employees Without Sales',
    NULL, NULL, NULL, NULL, NULL,
    E.EmpleadoID,
    E.Nombre,
    NULL, NULL, NULL, NULL, NULL, NULL
FROM Empleados E
WHERE E.EmpleadoID NOT IN (SELECT DISTINCT EmpleadoID FROM Ventas)

UNION ALL

SELECT
    'Query 4: Customer Sales History',
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    C.ClienteID,
    V.FechaVenta,
    NULL,
    NULL
FROM Clientes C
INNER JOIN Ventas V ON C.ClienteID = V.ClienteID

UNION ALL

SELECT
    'Query 5: Total Units Sold by Product',
    NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    P.NombreProducto,
    SUM(V.Cantidad),
    NULL, NULL, NULL, NULL
FROM Ventas V
INNER JOIN Productos P ON V.ProductoID = P.ProductoID
GROUP BY P.ProductoID, P.NombreProducto

UNION ALL

SELECT
    'Query 6: Employee Sales Above Threshold',
    NULL, NULL, NULL, NULL, NULL, NULL,
    E.Nombre,
    NULL, NULL, NULL, NULL, NULL, NULL
FROM Empleados E
INNER JOIN Ventas V ON E.EmpleadoID = V.EmpleadoID
GROUP BY E.EmpleadoID, E.Nombre
HAVING SUM(V.Monto) > 10000

UNION ALL

SELECT
    'Query 7: Customer Purchase History (CTE)',
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    ClienteID,
    FechaVenta,
    Nivel,
    NULL
FROM HistorialCompras

UNION ALL

SELECT
    'Query 8: Products Sold in Multiple Branches',
    NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
    P.NombreProducto,
    COUNT(DISTINCT V.SucursalID)
FROM Ventas V
INNER JOIN Productos P ON V.ProductoID = P.ProductoID
GROUP BY P.ProductoID, P.NombreProducto
HAVING COUNT(DISTINCT V.SucursalID) > 3;

SELECT TABLE_SCHEMA, TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE';

COMMIT