/*
    Retail Chain Management System - Niveles de Aislamiento Simplificado
    Final Project - Advanced Database
    ITLA

    Este script EJECUTA ejemplos de los diferentes niveles de aislamiento en SQL Server:
    - READ UNCOMMITTED
    - READ COMMITTED
    - REPEATABLE READ
    - SERIALIZABLE
    - SNAPSHOT
*/

USE RetailChainDB;
GO

-- ========================
-- Preparación de datos para pruebas
-- ========================

-- Crea una tabla temporal para las pruebas
IF OBJECT_ID('tempdb..#TempIsolationTest') IS NOT NULL
    DROP TABLE #TempIsolationTest;

CREATE TABLE #TempIsolationTest (
    ID INT PRIMARY KEY,
    ProductName NVARCHAR(100),
    Price DECIMAL(10, 2)
);

-- Inserta datos de prueba
INSERT INTO #TempIsolationTest (ID, ProductName, Price)
VALUES (1, 'Laptop', 1200),
       (2, 'Smartphone', 800),
       (3, 'Tablet', 500);

-- ========================
-- 1. READ UNCOMMITTED (Nivel más bajo)
-- ========================
PRINT '=== DEMOSTRACIÓN DE READ UNCOMMITTED ===';

-- Iniciamos una transacción pero no la completamos
BEGIN TRANSACTION;
    PRINT 'Actualizando precio de Laptop a 1500...';
    UPDATE #TempIsolationTest SET Price = 1500 WHERE ID = 1;
    
    -- Mostrar datos después de la actualización (dentro de la transacción)
    PRINT 'Datos dentro de la transacción:';
    SELECT * FROM #TempIsolationTest;
    
    -- Ahora veamos cómo se ven los datos con READ UNCOMMITTED desde otra "conexión"
    PRINT 'Simulando consulta desde otra conexión con READ UNCOMMITTED:';
    
    -- Usamos un bloque de ejecución con un nivel de aislamiento diferente
    EXEC('
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        PRINT ''Consultando datos con READ UNCOMMITTED:'';
        SELECT * FROM #TempIsolationTest;
    ');
    
    -- Volvemos a leer con READ COMMITTED para ver la diferencia
    PRINT 'Simulando consulta desde otra conexión con READ COMMITTED (nivel por defecto):';
    
    EXEC('
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        PRINT ''Consultando datos con READ COMMITTED:'';
        SELECT * FROM #TempIsolationTest;
        -- Esta consulta se bloqueará hasta que la transacción termine
    ');

-- Hacemos rollback para deshacer los cambios
ROLLBACK TRANSACTION;
PRINT 'Transacción revertida (ROLLBACK)';

-- Verificamos que el precio ha vuelto a su valor original
PRINT 'Datos después de ROLLBACK:';
SELECT * FROM #TempIsolationTest;

PRINT '';

-- ========================
-- 2. REPEATABLE READ y datos fanstasma
-- ========================
PRINT '=== DEMOSTRACIÓN DE REPEATABLE READ vs READ COMMITTED ===';

-- Primero, veamos qué pasa con READ COMMITTED
PRINT 'Con READ COMMITTED:';
BEGIN TRANSACTION;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    
    -- Primera lectura: productos con precio < 1000
    PRINT 'Primera lectura - productos con precio < 1000:';
    SELECT * FROM #TempIsolationTest WHERE Price < 1000;
    
    -- Simulamos que otra conexión actualiza un precio
    EXEC('
        UPDATE #TempIsolationTest SET Price = 950 WHERE ID = 1;
        PRINT ''Otra conexión cambió el precio del Laptop a 950'';
    ');
    
    -- Segunda lectura: el mismo rango
    PRINT 'Segunda lectura - productos con precio < 1000:';
    SELECT * FROM #TempIsolationTest WHERE Price < 1000;
    -- Con READ COMMITTED, veremos la fila 1 (Laptop) que ahora tiene precio 950
    
COMMIT TRANSACTION;

-- Devolvemos el precio original
UPDATE #TempIsolationTest SET Price = 1200 WHERE ID = 1;
PRINT 'Precio de Laptop restaurado a 1200';

-- Ahora veamos qué pasa con REPEATABLE READ
PRINT 'Con REPEATABLE READ:';
BEGIN TRANSACTION;
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    
    -- Primera lectura: productos con precio < 1000
    PRINT 'Primera lectura - productos con precio < 1000:';
    SELECT * FROM #TempIsolationTest WHERE Price < 1000;
    
    -- Simulamos que otra conexión intenta actualizar un precio
    -- Esto se bloqueará hasta que la transacción termine
    PRINT 'Otra conexión intenta cambiar el precio, pero se bloqueará...';
    
    -- El código siguiente haría un deadlock si se ejecutara en otra sesión,
    -- por lo que lo comentamos y solo mostramos lo que pasaría
    /*
    EXEC('
        UPDATE #TempIsolationTest SET Price = 950 WHERE ID = 1;
        PRINT ''Otra conexión cambió el precio del Laptop a 950'';
    ');
    */
    
    -- Segunda lectura: el mismo rango
    PRINT 'Segunda lectura - productos con precio < 1000:';
    SELECT * FROM #TempIsolationTest WHERE Price < 1000;
    -- Con REPEATABLE READ, veremos el mismo resultado que en la primera consulta
    
COMMIT TRANSACTION;

PRINT '';

-- ========================
-- 3. SERIALIZABLE y lecturas fantasma
-- ========================
PRINT '=== DEMOSTRACIÓN DE SERIALIZABLE vs REPEATABLE READ ===';

-- Primero, veamos qué pasa con REPEATABLE READ
PRINT 'Con REPEATABLE READ:';
BEGIN TRANSACTION;
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    
    -- Primera lectura: productos con precios entre 400 y 900
    PRINT 'Primera lectura - productos con precio entre 400 y 900:';
    SELECT * FROM #TempIsolationTest WHERE Price BETWEEN 400 AND 900;
    
    -- Simulamos que otra conexión inserta un nuevo producto en ese rango
    EXEC('
        INSERT INTO #TempIsolationTest (ID, ProductName, Price)
        VALUES (4, ''Headphones'', 600);
        PRINT ''Otra conexión insertó un nuevo producto: Headphones $600'';
    ');
    
    -- Segunda lectura: el mismo rango
    PRINT 'Segunda lectura - productos con precio entre 400 y 900:';
    SELECT * FROM #TempIsolationTest WHERE Price BETWEEN 400 AND 900;
    -- Con REPEATABLE READ, veremos el nuevo producto (lectura fantasma)
    
COMMIT TRANSACTION;

-- Eliminamos el producto insertado
DELETE FROM #TempIsolationTest WHERE ID = 4;
PRINT 'Producto Headphones eliminado';

-- Ahora veamos qué pasa con SERIALIZABLE
PRINT 'Con SERIALIZABLE:';
BEGIN TRANSACTION;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    
    -- Primera lectura: productos con precios entre 400 y 900
    PRINT 'Primera lectura - productos con precio entre 400 y 900:';
    SELECT * FROM #TempIsolationTest WHERE Price BETWEEN 400 AND 900;
    
    -- Simulamos que otra conexión intenta insertar un nuevo producto en ese rango
    -- Esto se bloqueará hasta que la transacción termine
    PRINT 'Otra conexión intenta insertar un producto, pero se bloqueará...';
    
    -- El código siguiente haría un deadlock si se ejecutara en otra sesión,
    -- por lo que lo comentamos y solo mostramos lo que pasaría
    /*
    EXEC('
        INSERT INTO #TempIsolationTest (ID, ProductName, Price)
        VALUES (4, ''Headphones'', 600);
        PRINT ''Otra conexión insertó un nuevo producto: Headphones $600'';
    ');
    */
    
    -- Segunda lectura: el mismo rango
    PRINT 'Segunda lectura - productos con precio entre 400 y 900:';
    SELECT * FROM #TempIsolationTest WHERE Price BETWEEN 400 AND 900;
    -- Con SERIALIZABLE, veremos exactamente el mismo resultado que en la primera consulta
    
COMMIT TRANSACTION;

PRINT '';

-- ========================
-- 4. SNAPSHOT Isolation
-- ========================
PRINT '=== DEMOSTRACIÓN DE SNAPSHOT ISOLATION ===';

-- Primero debemos habilitar SNAPSHOT en la base de datos
IF (SELECT snapshot_isolation_state FROM sys.databases WHERE name = 'RetailChainDB') = 0
BEGIN
    PRINT 'Habilitando SNAPSHOT ISOLATION para la base de datos...';
    ALTER DATABASE RetailChainDB SET ALLOW_SNAPSHOT_ISOLATION ON;
END

-- Ahora demostramos cómo funciona SNAPSHOT
PRINT 'Transacción 1 - modificando datos:';
BEGIN TRANSACTION;
    
    UPDATE #TempIsolationTest SET Price = 1500 WHERE ID = 1;
    PRINT 'Precio de Laptop actualizado a 1500';
    
    -- Ahora desde otra "conexión" con SNAPSHOT
    PRINT 'Simulando consulta desde otra conexión con SNAPSHOT:';
    
    EXEC('
        SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
        BEGIN TRANSACTION;
            PRINT ''Consultando datos con SNAPSHOT (verá la versión anterior):'';
            SELECT * FROM #TempIsolationTest;
        COMMIT TRANSACTION;
    ');
    
    -- Ahora desde otra "conexión" con READ COMMITTED
    PRINT 'Simulando consulta desde otra conexión con READ COMMITTED:';
    
    EXEC('
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        PRINT ''Consultando datos con READ COMMITTED (esperará o verá la nueva versión):'';
        SELECT * FROM #TempIsolationTest;
    ');
    
COMMIT TRANSACTION;
PRINT 'Transacción 1 completada (COMMIT)';

-- Restauramos el precio
UPDATE #TempIsolationTest SET Price = 1200 WHERE ID = 1;
PRINT 'Precio de Laptop restaurado a 1200';

PRINT '';

-- ========================
-- Limpiar
-- ========================
PRINT '=== LIMPIEZA ===';
DROP TABLE #TempIsolationTest;
PRINT 'Tabla temporal eliminada';

GO