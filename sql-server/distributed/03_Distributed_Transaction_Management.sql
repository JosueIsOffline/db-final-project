/*
    Retail Chain Management System - Distributed Transaction Management
    Final Project - Advanced Database
    ITLA

    ===========Fallos en transacciones distribuidas===========


    Para manejar fallos en transacciones distribuidas, SQL Server utiliza un protocolo de dos fases, 
    (Two-Phases-Commit, 2PC), el cual se encarga de asegugar la consistencia de las transacciones distribuidas.

    Este protocolo se divive en dos faces:

    -Fase 1: Preparación (Prepare): En esta fase SQL Server notifica a todas las bases de datos que estén involucradas 
    en la transación distribuida para que realicen las operaciones necesarias. Cada base de datos responde con un "Listo",
    si puede seguir adelante o "Abortar", si hay algún problema.

    -Fase 2: Compromiso o Deshacer (Commit/Rollback): Ya en esta fase si todas las bases de datos han respondido afirmativamente 
    en la Fase 1, se procede a hacer el "commit", confirmando que la transacción fue exitosa. Si alguna base de datos 
    respondió con un "Abortar", se realiza un "rollback" en todas las bases de datos involucradas para deshacer los cambios.

    ===========¿Cómo se manejan los fallos?===========

    Si ocurre un fallo en alguna de las bases de datos durante la transacción, el sistema garantiza la consistencia de los 
    datos al hacer un rollback de todos los cambios.

    SQL Server utiliza el Distributed Transaction Coordinator (DTC) para gestionar y coordinar transacciones distribuidas 
    y manejar fallos. Si un fallo ocurre después de que algunas bases de datos hayan confirmado el commit, el DTC asegura 
    que se reviertan todos los cambios en las bases de datos participantes para mantener la atomicidad.

    Esto asegura que, incluso en situaciones de error, las bases de datos involucradas se mantengan consistentes y 
    no haya incoherencia entre ellas.

