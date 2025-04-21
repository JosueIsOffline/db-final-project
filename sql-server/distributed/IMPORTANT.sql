EXEC sp_addlinkedserver 
    @server = 'LOOPBACK', -- nombre del linked server (puede ser cualquiera)
    @srvproduct = '',
    @provider = 'SQLNCLI11', -- o 'SQLNCLI10' segun tu version
    @datasrc = 'ASUSROG\SQLEXPRESS3'; -- o el nombre de tu instancia, como 'MI_SERVIDOR\SQL2022'
