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
-- Preparaci�n de datos para pruebas
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
-- 1. READ UNCOMMITTED (Nivel m�s bajo)
-- ========================
PRINT '=== DEMOSTRACI�N DE READ UNCOMMITTED ===';

-- Iniciamos una transacci�n pero no la completamos
BEGIN TRANSACTION;
    PRINT 'Actualizando precio de Laptop a 1500...';
    UPDATE #TempIsolationTest SET Price = 1500 WHERE ID = 1;
    
    -- Mostrar datos despu�s de la actualizaci�n (dentro de la transacci�n)
    PRINT 'Datos dentro de la transacci�n:';
    SELECT * FROM #TempIsolationTest;
    
    -- Ahora veamos c�mo se ven los datos con READ UNCOMMITTED desde otra "conexi�n"
    PRINT 'Simulando consulta desde otra conexi�n con READ UNCOMMITTED:';
    
    -- Usamos un bloque de ejecuci�n con un nivel de aislamiento diferente
    EXEC('
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
        PRINT ''Consultando datos con READ UNCOMMITTED:'';
        SELECT * FROM #TempIsolationTest;
    ');
    
    -- Volvemos a leer con READ COMMITTED para ver la diferencia
    PRINT 'Simulando consulta desde otra conexi�n con READ COMMITTED (nivel por defecto):';
    
    EXEC('
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        PRINT ''Consultando datos con READ COMMITTED:'';
        SELECT * FROM #TempIsolationTest;
        -- Esta consulta se bloquear� hasta que la transacci�n termine
    ');

-- Hacemos rollback para deshacer los cambios
ROLLBACK TRANSACTION;
PRINT 'Transacci�n revertida (ROLLBACK)';

-- Verificamos que el precio ha vuelto a su valor original
PRINT 'Datos despu�s de ROLLBACK:';
SELECT * FROM #TempIsolationTest;

PRINT '';

-- ========================
-- 2. REPEATABLE READ y datos fanstasma
-- ========================
PRINT '=== DEMOSTRACI�N DE REPEATABLE READ vs READ COMMITTED ===';

-- Primero, veamos qu� pasa con READ COMMITTED
PRINT 'Con READ COMMITTED:';
BEGIN TRANSACTION;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    
    -- Primera lectura: productos con precio < 1000
    PRINT 'Primera lectura - productos con precio < 1000:';
    SELECT * FROM #TempIsolationTest WHERE Price < 1000;
    
    -- Simulamos que otra conexi�n actualiza un precio
    EXEC('
        UPDATE #TempIsolationTest SET Price = 950 WHERE ID = 1;
        PRINT ''Otra conexi�n cambi� el precio del Laptop a 950'';
    ');
    
    -- Segunda lectura: el mismo rango
    PRINT 'Segunda lectura - productos con precio < 1000:';
    SELECT * FROM #TempIsolationTest WHERE Price < 1000;
    -- Con READ COMMITTED, veremos la fila 1 (Laptop) que ahora tiene precio 950
    
COMMIT TRANSACTION;

-- Devolvemos el precio original
UPDATE #TempIsolationTest SET Price = 1200 WHERE ID = 1;
PRINT 'Precio de Laptop restaurado a 1200';

-- Ahora veamos qu� pasa con REPEATABLE READ
PRINT 'Con REPEATABLE READ:';
BEGIN TRANSACTION;
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    
    -- Primera lectura: productos con precio < 1000
    PRINT 'Primera lectura - productos con precio < 1000:';
    SELECT * FROM #TempIsolationTest WHERE Price < 1000;
    
    -- Simulamos que otra conexi�n intenta actualizar un precio
    -- Esto se bloquear� hasta que la transacci�n termine
    PRINT 'Otra conexi�n intenta cambiar el precio, pero se bloquear�...';
    
    -- El c�digo siguiente har�a un deadlock si se ejecutara en otra sesi�n,
    -- por lo que lo comentamos y solo mostramos lo que pasar�a
    /*
    EXEC('
        UPDATE #TempIsolationTest SET Price = 950 WHERE ID = 1;
        PRINT ''Otra conexi�n cambi� el precio del Laptop a 950'';
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
PRINT '=== DEMOSTRACI�N DE SERIALIZABLE vs REPEATABLE READ ===';

-- Primero, veamos qu� pasa con REPEATABLE READ
PRINT 'Con REPEATABLE READ:';
BEGIN TRANSACTION;
    SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    
    -- Primera lectura: productos con precios entre 400 y 900
    PRINT 'Primera lectura - productos con precio entre 400 y 900:';
    SELECT * FROM #TempIsolationTest WHERE Price BETWEEN 400 AND 900;
    
    -- Simulamos que otra conexi�n inserta un nuevo producto en ese rango
    EXEC('
        INSERT INTO #TempIsolationTest (ID, ProductName, Price)
        VALUES (4, ''Headphones'', 600);
        PRINT ''Otra conexi�n insert� un nuevo producto: Headphones $600'';
    ');
    
    -- Segunda lectura: el mismo rango
    PRINT 'Segunda lectura - productos con precio entre 400 y 900:';
    SELECT * FROM #TempIsolationTest WHERE Price BETWEEN 400 AND 900;
    -- Con REPEATABLE READ, veremos el nuevo producto (lectura fantasma)
    
COMMIT TRANSACTION;

-- Eliminamos el producto insertado
DELETE FROM #TempIsolationTest WHERE ID = 4;
PRINT 'Producto Headphones eliminado';

-- Ahora veamos qu� pasa con SERIALIZABLE
PRINT 'Con SERIALIZABLE:';
BEGIN TRANSACTION;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    
    -- Primera lectura: productos con precios entre 400 y 900
    PRINT 'Primera lectura - productos con precio entre 400 y 900:';
    SELECT * FROM #TempIsolationTest WHERE Price BETWEEN 400 AND 900;
    
    -- Simulamos que otra conexi�n intenta insertar un nuevo producto en ese rango
    -- Esto se bloquear� hasta que la transacci�n termine
    PRINT 'Otra conexi�n intenta insertar un producto, pero se bloquear�...';
    
    -- El c�digo siguiente har�a un deadlock si se ejecutara en otra sesi�n,
    -- por lo que lo comentamos y solo mostramos lo que pasar�a
    /*
    EXEC('
        INSERT INTO #TempIsolationTest (ID, ProductName, Price)
        VALUES (4, ''Headphones'', 600);
        PRINT ''Otra conexi�n insert� un nuevo producto: Headphones $600'';
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
PRINT '=== DEMOSTRACI�N DE SNAPSHOT ISOLATION ===';

-- Primero debemos habilitar SNAPSHOT en la base de datos
IF (SELECT snapshot_isolation_state FROM sys.databases WHERE name = 'RetailChainDB') = 0
BEGIN
    PRINT 'Habilitando SNAPSHOT ISOLATION para la base de datos...';
    ALTER DATABASE RetailChainDB SET ALLOW_SNAPSHOT_ISOLATION ON;
END

-- Ahora demostramos c�mo funciona SNAPSHOT
PRINT 'Transacci�n 1 - modificando datos:';
BEGIN TRANSACTION;
    
    UPDATE #TempIsolationTest SET Price = 1500 WHERE ID = 1;
    PRINT 'Precio de Laptop actualizado a 1500';
    
    -- Ahora desde otra "conexi�n" con SNAPSHOT
    PRINT 'Simulando consulta desde otra conexi�n con SNAPSHOT:';
    
    EXEC('
        SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
        BEGIN TRANSACTION;
            PRINT ''Consultando datos con SNAPSHOT (ver� la versi�n anterior):'';
            SELECT * FROM #TempIsolationTest;
        COMMIT TRANSACTION;
    ');
    
    -- Ahora desde otra "conexi�n" con READ COMMITTED
    PRINT 'Simulando consulta desde otra conexi�n con READ COMMITTED:';
    
    EXEC('
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        PRINT ''Consultando datos con READ COMMITTED (esperar� o ver� la nueva versi�n):'';
        SELECT * FROM #TempIsolationTest;
    ');
    
COMMIT TRANSACTION;
PRINT 'Transacci�n 1 completada (COMMIT)';

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