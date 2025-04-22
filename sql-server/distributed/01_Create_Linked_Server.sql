/*
    Retail Chain Management System - Linked Server Configuration
    Final Project - Advanced Database
    ITLA

    --Descripción:
    Este script configura un servidor vinculado denominado LOCAL en SQL Server, 
    permitiendo que la instancia actual de SQL Server se conecte a sí misma. 
    Esto facilita la ejecución de consultas distribuidas dentro del entorno de la 
    base de datos RetailChainDB, habilitando el acceso a datos entre diferentes servidores.

    --Propósito:
    - Crear un Linked Server 'LOCAL' en la instancia actual.
    - Habilitar consultas distribuidas entre servidores en RetailChainDB.

    --Acciones del script:
    1.Obtención del nombre del servidor actual: Utiliza la función @@SERVERNAME para 
    identificar el nombre de la instancia de SQL Server.
    2.Creación del servidor vinculado: Ejecuta el procedimiento almacenado sp_addlinkedserver 
    para configurar el servidor vinculado LOCAL utilizando el proveedor SQLNCLI11.
    3.Confirmación: Imprime un mensaje confirmando la creación exitosa del servidor vinculado.

    --Detalles del Script:
    - @server: Nombre del Likned Server ('LOCAL').
    - @srvproduct: Producto del servidor (se deja vacóo ya que es SQL Serve).
    - @provider: Proveedor OLE DB ('SQLNCLI11') utilizado para la conexión..
    - @datasrc: El nombre de la instancia actual de SQL Server, obtenido dinámicamente 
      mediante @@SERVERNAME.

    --Instrucciones:
    1. Ejecute el script en la base de datos 'master'.
    2. Verifique el mensaje de confirmación de éxito.
*/

USE master
GO

DECLARE @CurrentServerName NVARCHAR(128)
DECLARE @SQL NVARCHAR(1000)


-- Obtener el nombre del servidor actual
SELECT @CurrentServerName = @@SERVERNAME


-- Configurar el servidor vinculado 'LOCAL'
SET @SQL = N'
EXEC sp_addlinkedserver 
    @server = ''LOCAL'', 
    @srvproduct = '''',
    @provider = ''SQLNCLI11'',
    @datasrc = ''' + @CurrentServerName + ''';'

-- Ejecutar la creación del Linked Server
EXECUTE sp_executesql @SQL


-- Confirmar que el Linked Server ha sido creado exitosamente
PRINT 'Linked Server LOCAL created successfully with datasrc = ' + @CurrentServerName;
GO




