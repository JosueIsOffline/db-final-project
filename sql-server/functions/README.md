# Functions

# Fase 5 - Procedimientos Almacenados, Funciones y Triggers

**Proyecto Final - Sistema de Gestión para Cadena de Tiendas (RetailChainDB)**  
**Materia: Base de Datos Avanzadas - ITLA**

---

## 📌 Objetivo

Desarrollar e implementar componentes programables en la base de datos `RetailChainDB` que automaticen procesos, refuercen la lógica de negocio y mejoren la auditoría del sistema.

Esta fase abarca:

- 3 procedimientos almacenados (`Stored Procedures`)
- 2 funciones (`Funciones Escalares` y `Funciones con Valor de Tabla`)
- 3 triggers (Auditoría, Validación de negocio y Actualización en cascada)

---

## 🧩 Procedimientos Almacenados (Stored Procedures)

### 1. `HR.AddNewEmployee`

**Propósito:** Agrega un nuevo empleado al sistema.

**Parámetros:**
- `@FirstName`, `@LastName`, `@Email`, `@Phone`, `@HireDate`, `@StoreID`, `@PositionID`

**Tabla afectada:** `HR.Employee`

---

### 2. `Sales.RegisterSale`

**Propósito:** Registra una venta con múltiples productos.

**Parámetros:**
- `@CustomerID`, `@EmployeeID`, `@StoreID`, `@ProductDetails` (tipo `READONLY` con productos)

**Tablas afectadas:**
- `Sales.Sale`
- `Sales.SaleDetail`
- `Inventory.Product`

---

### 3. `Inventory.TransferProductBetweenStores`

**Propósito:** Transfiere un producto entre dos sucursales.

**Parámetros:**
- `@ProductID`, `@FromStoreID`, `@ToStoreID`, `@Quantity`

**Validación incluida:** Verifica que haya suficiente stock antes de transferir.

**Tablas afectadas:**
- `Inventory.StoreProduct`

---

## 🧮 Funciones

### 1. `Sales.GetTotalSalesByStore` (Escalar)

**Propósito:** Retorna el total de ventas (monto) de una tienda específica.

**Parámetro:** `@StoreID`

**Retorno:** `MONEY`

**Consulta interna:** Suma del total vendido multiplicando cantidad × precio.

---

### 2. `Sales.GetEmployeeSales` (Tabla)

**Propósito:** Devuelve todas las ventas hechas por un empleado con sus detalles.

**Parámetro:** `@EmployeeID`

**Retorno:** Tabla con columnas:
- `SaleID`, `SaleDate`, `ProductID`, `Quantity`, `UnitPrice`, `Total`

---

## ⚠️ Triggers

### 1. `Inventory.trg_Audit_ProductUpdate` (Auditoría)

**Disparador:** `AFTER UPDATE` sobre `Inventory.Product`

**Acción:** Inserta en `Audit.ProductChanges` el cambio de nombre de un producto.

---

### 2. `Inventory.trg_Check_Stock_Not_Negative` (Regla de Negocio)

**Disparador:** `INSTEAD OF INSERT, UPDATE` sobre `Inventory.StoreProduct`

**Acción:** Evita que se inserten o actualicen productos con stock negativo.  
También realiza `MERGE` para insertar o actualizar según corresponda.

---

### 3. `trg_UpdateCountry` (Cascada)

**Disparador:** `AFTER UPDATE` sobre `Store.Country`

**Acción:** Actualiza el nombre de las regiones (`Store.Region`) asociadas al país modificado.

---

## ✅ Conclusiones

Esta fase refuerza la automatización, integridad y control del sistema `RetailChainDB`, alineándose con buenas prácticas en diseño de bases de datos avanzadas.

Los objetos creados aseguran:

- Reducción de errores por validación automática
- Seguimiento de cambios críticos (auditoría)
- Mantenimiento de consistencia entre tablas relacionadas

---