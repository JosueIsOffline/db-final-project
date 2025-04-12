/*
    Retail Chain Management System - Script de Monitoreo
    Final Project - Advanced Database
    ITLA
    
    Este script permite monitorear el progreso de inserciones de datos
    en las tablas principales y de auditoría de RetailChainDB.
*/

USE RetailChainDB;
GO

-- Establecer el nivel de aislamiento para no bloquear durante las inserciones masivas
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- Consulta para monitorear progreso de inserciones de datos
SELECT 
    'Hora actual' AS Información, 
    CONVERT(VARCHAR, GETDATE(), 120) AS Valor
UNION ALL
SELECT '--- Tablas de Ubicación ---', ''
UNION ALL
SELECT 'Países', CAST(COUNT(*) AS VARCHAR) FROM Store.Country WITH (NOLOCK)
UNION ALL
SELECT 'Regiones', CAST(COUNT(*) AS VARCHAR) FROM Store.Region WITH (NOLOCK)
UNION ALL
SELECT 'Ciudades', CAST(COUNT(*) AS VARCHAR) FROM Store.City WITH (NOLOCK)
UNION ALL
SELECT '--- Tablas de Tienda ---', ''
UNION ALL
SELECT 'Tipos de Tienda', CAST(COUNT(*) AS VARCHAR) FROM Store.StoreType WITH (NOLOCK)
UNION ALL
SELECT 'Tiendas', CAST(COUNT(*) AS VARCHAR) FROM Store.Store WITH (NOLOCK)
UNION ALL
SELECT '--- Tablas de Recursos Humanos ---', ''
UNION ALL
SELECT 'Departamentos', CAST(COUNT(*) AS VARCHAR) FROM HR.Department WITH (NOLOCK)
UNION ALL
SELECT 'Posiciones', CAST(COUNT(*) AS VARCHAR) FROM HR.Position WITH (NOLOCK)
UNION ALL
SELECT 'Empleados', CAST(COUNT(*) AS VARCHAR) FROM HR.Employee WITH (NOLOCK)
UNION ALL
SELECT 'Horarios', CAST(COUNT(*) AS VARCHAR) FROM HR.Schedule WITH (NOLOCK)
UNION ALL
SELECT '--- Tablas de Inventario ---', ''
UNION ALL
SELECT 'Categorías', CAST(COUNT(*) AS VARCHAR) FROM Inventory.Category WITH (NOLOCK)
UNION ALL
SELECT 'Proveedores', CAST(COUNT(*) AS VARCHAR) FROM Inventory.Supplier WITH (NOLOCK)
UNION ALL
SELECT 'Productos', CAST(COUNT(*) AS VARCHAR) FROM Inventory.Product WITH (NOLOCK)
UNION ALL
SELECT 'Inventario por Tienda', CAST(COUNT(*) AS VARCHAR) FROM Inventory.StoreInventory WITH (NOLOCK)
UNION ALL
SELECT 'Transacciones de Inventario', CAST(COUNT(*) AS VARCHAR) FROM Inventory.InventoryTransaction WITH (NOLOCK)
UNION ALL
SELECT '--- Tablas de Ventas y Clientes ---', ''
UNION ALL
SELECT 'Niveles de Lealtad', CAST(COUNT(*) AS VARCHAR) FROM Sales.LoyaltyLevel WITH (NOLOCK)
UNION ALL
SELECT 'Clientes', CAST(COUNT(*) AS VARCHAR) FROM Sales.Customer WITH (NOLOCK)
UNION ALL
SELECT 'Métodos de Pago', CAST(COUNT(*) AS VARCHAR) FROM Sales.PaymentMethod WITH (NOLOCK)
UNION ALL
SELECT 'Promociones', CAST(COUNT(*) AS VARCHAR) FROM Sales.Promotion WITH (NOLOCK)
UNION ALL
SELECT 'Promociones por Producto', CAST(COUNT(*) AS VARCHAR) FROM Sales.ProductPromotion WITH (NOLOCK)
UNION ALL
SELECT 'Ventas', CAST(COUNT(*) AS VARCHAR) FROM Sales.Sale WITH (NOLOCK)
UNION ALL
SELECT 'Detalles de Ventas', CAST(COUNT(*) AS VARCHAR) FROM Sales.SaleDetail WITH (NOLOCK)
UNION ALL
SELECT '--- Tablas de Auditoría ---', ''
UNION ALL
SELECT 'Cambios de Esquema', CAST(COUNT(*) AS VARCHAR) FROM Audit.SchemaChanges WITH (NOLOCK)
UNION ALL
SELECT 'Historial de Precios', CAST(COUNT(*) AS VARCHAR) FROM Audit.PriceHistory WITH (NOLOCK)
UNION ALL
SELECT 'Historial de Empleados', CAST(COUNT(*) AS VARCHAR) FROM Audit.EmployeeHistory WITH (NOLOCK)
UNION ALL
SELECT 'Intentos de Acceso', CAST(COUNT(*) AS VARCHAR) FROM Audit.LoginAttempt WITH (NOLOCK);

-- Restaurar el nivel de aislamiento predeterminado
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;