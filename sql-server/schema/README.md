# Schema

Scripts de creación de tablas y estructura de la base de datos

# Resumen del Esquema de Base de Datos - Sistema de Gestión para Cadena Minorista

El esquema de base de datos implementa una solución completa para gestionar una cadena minorista con múltiples sucursales. Está organizado en esquemas lógicos que agrupan tablas relacionadas:

## Esquema Store
Contiene tablas para datos geográficos (Country, Region, City) e información de tiendas (Store, StoreType). La estructura jerárquica permite operaciones internacionales con seguimiento adecuado de ubicaciones.

## Esquema HR
Gestiona todos los datos relacionados con empleados, incluyendo departamentos, puestos, detalles de empleados y horarios de trabajo. Admite jerarquía organizacional mediante relaciones auto-referenciadas en la tabla Employee.

## Esquema Inventory
Maneja la gestión de productos con categorías jerárquicas, información de proveedores, detalles de productos, niveles de inventario por tienda y transacciones de inventario. Incluye funciones para seguimiento de stock, niveles mínimos e historial de movimientos.

## Esquema Sales
Administra información de clientes, programas de fidelización, transacciones de ventas, promociones y métodos de pago. El esquema permite un seguimiento detallado de ventas con tablas de encabezado y líneas de detalle.

## Esquema Audit
Proporciona seguimiento completo de cambios críticos, incluyendo modificaciones de precios, cambios de estado de empleados, alteraciones del esquema y eventos de seguridad.

El esquema incluye manejo de referencias circulares (Store-Employee) y está diseñado con normalización adecuada e índices optimizados para consultas comunes.