// Script para generar datos masivos en RetailChainDB
// Ejecuta esto en Mongosh conectado a tu base de datos

// Usa la base de datos RetailChainDB
db = db.getSiblingDB('RetailChainDB');

// Función para crear una fecha aleatoria en un rango
function randomDate(start, end) {
  return new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));
}

// Función para generar un número aleatorio en un rango
function randomInt(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

// Función para elegir un elemento aleatorio de un array
function randomItem(array) {
  return array[Math.floor(Math.random() * array.length)];
}

// Eliminar todas las colecciones existentes
db.getCollectionNames().forEach(function(collection) {
    if (collection !== "system.views") {
      db[collection].drop();
    }
  });

  // Crear colecciones sin validación estricta o con validación mínima
db.createCollection("countries");
db.createCollection("regions");
db.createCollection("cities");
db.createCollection("storeTypes");
db.createCollection("stores");
db.createCollection("departments");
db.createCollection("positions");
db.createCollection("employees");
db.createCollection("categories");
db.createCollection("suppliers");
db.createCollection("products");
db.createCollection("inventory");
db.createCollection("loyaltyLevels");
db.createCollection("customers");
db.createCollection("paymentMethods");
db.createCollection("promotions");
db.createCollection("sales");
db.createCollection("inventoryTransactions");
db.createCollection("auditLogs");
db.createCollection("loginAttempts");

// Primero, limpiar las colecciones existentes (opcional)
db.countries.deleteMany({});
db.regions.deleteMany({});
db.cities.deleteMany({});
db.storeTypes.deleteMany({});
db.stores.deleteMany({});
db.departments.deleteMany({});
db.positions.deleteMany({});
db.employees.deleteMany({});
db.categories.deleteMany({});
db.suppliers.deleteMany({});
db.products.deleteMany({});
db.inventory.deleteMany({});
db.loyaltyLevels.deleteMany({});
db.customers.deleteMany({});
db.paymentMethods.deleteMany({});
db.promotions.deleteMany({});
db.sales.deleteMany({});

// Crear países
const countries = [
  { countryName: "Estados Unidos", countryCode: "US", isActive: true, createdDate: new Date() },
  { countryName: "México", countryCode: "MX", isActive: true, createdDate: new Date() },
  { countryName: "Canadá", countryCode: "CA", isActive: true, createdDate: new Date() },
  { countryName: "España", countryCode: "ES", isActive: true, createdDate: new Date() },
  { countryName: "Colombia", countryCode: "CO", isActive: true, createdDate: new Date() }
];
const countryIds = db.countries.insertMany(countries).insertedIds;
print(`Insertados ${countries.length} países`);

// Crear regiones
const regions = [];
const regionNames = {
  "US": ["California", "Texas", "New York", "Florida", "Illinois"],
  "MX": ["Ciudad de México", "Jalisco", "Nuevo León", "Yucatán", "Baja California"],
  "CA": ["Ontario", "Quebec", "British Columbia", "Alberta", "Manitoba"],
  "ES": ["Madrid", "Cataluña", "Andalucía", "Valencia", "País Vasco"],
  "CO": ["Bogotá", "Antioquia", "Valle del Cauca", "Atlántico", "Santander"]
};

Object.entries(countryIds).forEach(([index, countryId]) => {
  const countryCode = countries[index].countryCode;
  const names = regionNames[countryCode] || [];
  
  names.forEach(name => {
    regions.push({
      regionName: name,
      countryId: countryId,
      isActive: true,
      createdDate: new Date()
    });
  });
});

const regionIds = db.regions.insertMany(regions).insertedIds;
print(`Insertadas ${regions.length} regiones`);

// Crear ciudades
const cities = [];
const cityNames = {
  "California": ["Los Angeles", "San Francisco", "San Diego", "Sacramento", "Oakland"],
  "Texas": ["Houston", "Dallas", "Austin", "San Antonio", "El Paso"],
  "Ciudad de México": ["Coyoacán", "Tlalpan", "Polanco", "Santa Fe", "Xochimilco"],
  "Jalisco": ["Guadalajara", "Puerto Vallarta", "Zapopan", "Tlaquepaque", "Tonalá"],
  "Madrid": ["Madrid Centro", "Alcobendas", "Móstoles", "Getafe", "Alcalá de Henares"],
  "Cataluña": ["Barcelona", "Tarragona", "Girona", "Lleida", "Hospitalet"],
  "Bogotá": ["Chapinero", "Usaquén", "Suba", "Kennedy", "Teusaquillo"],
  "Antioquia": ["Medellín", "Envigado", "Bello", "Itagüí", "Rionegro"]
};

Object.entries(regionIds).forEach(([index, regionId]) => {
  const regionName = regions[index].regionName;
  const names = cityNames[regionName] || [`${regionName} City`, `${regionName} Downtown`, `${regionName} East`, `${regionName} West`, `${regionName} North`];
  
  names.forEach(name => {
    cities.push({
      cityName: name,
      regionId: regionId,
      postalCode: randomInt(10000, 99999).toString(),
      isActive: true,
      createdDate: new Date()
    });
  });
});

const cityIds = db.cities.insertMany(cities).insertedIds;
print(`Insertadas ${cities.length} ciudades`);

// Crear tipos de tiendas
const storeTypes = [
  { typeName: "Mall", description: "Tienda en centro comercial", isActive: true, createdDate: new Date() },
  { typeName: "Street", description: "Tienda a pie de calle", isActive: true, createdDate: new Date() },
  { typeName: "Outlet", description: "Tienda de descuentos", isActive: true, createdDate: new Date() },
  { typeName: "Flagship", description: "Tienda insignia", isActive: true, createdDate: new Date() },
  { typeName: "Corner", description: "Espacio dentro de otra tienda", isActive: true, createdDate: new Date() }
];
const storeTypeIds = db.storeTypes.insertMany(storeTypes).insertedIds;
print(`Insertados ${storeTypes.length} tipos de tienda`);

// Crear departamentos
const departments = [
  { departmentName: "Ventas", description: "Departamento de ventas y atención al cliente", isActive: true, createdDate: new Date() },
  { departmentName: "Administración", description: "Administración y finanzas", isActive: true, createdDate: new Date() },
  { departmentName: "Recursos Humanos", description: "Gestión del personal", isActive: true, createdDate: new Date() },
  { departmentName: "Almacén", description: "Gestión de inventario", isActive: true, createdDate: new Date() },
  { departmentName: "Marketing", description: "Promoción y publicidad", isActive: true, createdDate: new Date() }
];
const departmentIds = db.departments.insertMany(departments).insertedIds;
print(`Insertados ${departments.length} departamentos`);

// Crear puestos de trabajo
const positions = [];
const positionTitles = {
  "Ventas": ["Vendedor", "Gerente de Ventas", "Cajero", "Asesor de Cliente", "Supervisor de Tienda"],
  "Administración": ["Contador", "Asistente Administrativo", "Gerente Financiero", "Analista Financiero"],
  "Recursos Humanos": ["Especialista en RRHH", "Gerente de RRHH", "Reclutador", "Capacitador"],
  "Almacén": ["Encargado de Almacén", "Asistente de Almacén", "Inventarista", "Despachador"],
  "Marketing": ["Coordinador de Marketing", "Diseñador Gráfico", "Community Manager", "Analista de Mercado"]
};

Object.entries(departmentIds).forEach(([index, departmentId]) => {
  const departmentName = departments[index].departmentName;
  const titles = positionTitles[departmentName] || [];
  
  titles.forEach(title => {
    positions.push({
      positionTitle: title,
      departmentId: departmentId,
      department: { departmentName: departmentName },
      minSalary: randomInt(1000, 2000) * 10,
      maxSalary: randomInt(2500, 5000) * 10,
      isActive: true,
      createdDate: new Date()
    });
  });
});

const positionIds = db.positions.insertMany(positions).insertedIds;
print(`Insertados ${positions.length} puestos de trabajo`);

// Crear tiendas
const stores = [];
for (let i = 0; i < 20; i++) {
  const cityId = randomItem(Object.values(cityIds));
  const cityIndex = Object.values(cityIds).findIndex(id => id.equals(cityId));
  const city = cities[cityIndex];
  
  stores.push({
    storeName: `Tienda ${city.cityName} ${i + 1}`,
    storeCode: `ST-${randomInt(1000, 9999)}`,
    storeTypeId: randomItem(Object.values(storeTypeIds)),
    address: `Calle ${randomInt(1, 100)} #${randomInt(1, 999)}`,
    cityId: cityId,
    city: { cityName: city.cityName },
    phone: `(${randomInt(100, 999)}) ${randomInt(100, 999)}-${randomInt(1000, 9999)}`,
    email: `tienda${i+1}@retailchain.com`,
    openingDate: randomDate(new Date(2015, 0, 1), new Date(2023, 0, 1)),
    size: randomInt(50, 500) * 10,
    isActive: true,
    createdDate: new Date()
  });
}

const storeIds = db.stores.insertMany(stores).insertedIds;
print(`Insertadas ${stores.length} tiendas`);

// Crear empleados
const employees = [];
const firstNames = ["Juan", "María", "Carlos", "Ana", "Pedro", "Laura", "Miguel", "Sofía", "José", "Carmen", "Luis", "Elena", "David", "Rosa", "Francisco"];
const lastNames = ["García", "Rodríguez", "López", "Martínez", "González", "Hernández", "Pérez", "Sánchez", "Ramírez", "Torres", "Flores", "Rivera", "Gómez", "Díaz", "Reyes"];

// Primero, crear gerentes
const managers = [];
for (let i = 0; i < stores.length; i++) {
  const firstName = randomItem(firstNames);
  const lastName = randomItem(lastNames);
  const managerPosition = positions.find(p => p.positionTitle.includes("Gerente"));
  const positionId = positionIds[positions.indexOf(managerPosition)];
  
  managers.push({
    firstName: firstName,
    lastName: lastName,
    employeeCode: `EMP-${randomInt(1000, 9999)}`,
    email: `${firstName.toLowerCase()}.${lastName.toLowerCase()}@retailchain.com`,
    phone: `(${randomInt(100, 999)}) ${randomInt(100, 999)}-${randomInt(1000, 9999)}`,
    hireDate: randomDate(new Date(2015, 0, 1), new Date(2022, 0, 1)),
    birthDate: randomDate(new Date(1970, 0, 1), new Date(1995, 0, 1)),
    gender: randomItem(["M", "F"]),
    address: `Calle ${randomInt(1, 100)} #${randomInt(1, 999)}`,
    cityId: randomItem(Object.values(cityIds)),
    positionId: positionId,
    position: { positionTitle: managerPosition.positionTitle },
    storeId: storeIds[i],
    store: { storeName: stores[i].storeName },
    salary: randomInt(3000, 5000) * 10,
    isActive: true,
    createdDate: new Date()
  });
}

const managerIds = db.employees.insertMany(managers).insertedIds;
print(`Insertados ${managers.length} gerentes`);

// Actualizar tiendas con los gerentes
for (let i = 0; i < stores.length; i++) {
  db.stores.updateOne(
    { _id: storeIds[i] },
    { $set: { managerId: managerIds[i] } }
  );
}

// Crear resto de empleados
for (let i = 0; i < 100; i++) {
  const firstName = randomItem(firstNames);
  const lastName = randomItem(lastNames);
  const position = randomItem(positions);
  const positionId = positionIds[positions.indexOf(position)];
  const store = randomItem(stores);
  const storeId = storeIds[stores.indexOf(store)];
  const managerId = managerIds[stores.indexOf(store)];
  
  employees.push({
    firstName: firstName,
    lastName: lastName,
    employeeCode: `EMP-${randomInt(10000, 99999)}`,
    email: `${firstName.toLowerCase()}.${lastName.toLowerCase()}${randomInt(1, 999)}@retailchain.com`,
    phone: `(${randomInt(100, 999)}) ${randomInt(100, 999)}-${randomInt(1000, 9999)}`,
    hireDate: randomDate(new Date(2015, 0, 1), new Date(2023, 0, 1)),
    birthDate: randomDate(new Date(1970, 0, 1), new Date(2000, 0, 1)),
    gender: randomItem(["M", "F"]),
    address: `Calle ${randomInt(1, 100)} #${randomInt(1, 999)}`,
    cityId: randomItem(Object.values(cityIds)),
    positionId: positionId,
    position: { positionTitle: position.positionTitle },
    storeId: storeId,
    store: { storeName: store.storeName },
    reportsTo: managerId,
    manager: { 
      firstName: managers[stores.indexOf(store)].firstName,
      lastName: managers[stores.indexOf(store)].lastName
    },
    salary: randomInt(1500, 3000) * 10,
    isActive: Math.random() > 0.1, // 10% inactivos
    createdDate: new Date()
  });
}

const employeeIds = db.employees.insertMany(employees).insertedIds;
print(`Insertados ${employees.length} empleados adicionales`);

// Crear categorías de productos
const parentCategories = [
  { categoryName: "Ropa", description: "Prendas de vestir", isActive: true, createdDate: new Date() },
  { categoryName: "Calzado", description: "Todo tipo de calzado", isActive: true, createdDate: new Date() },
  { categoryName: "Accesorios", description: "Complementos de moda", isActive: true, createdDate: new Date() },
  { categoryName: "Deportes", description: "Artículos deportivos", isActive: true, createdDate: new Date() },
  { categoryName: "Hogar", description: "Artículos para el hogar", isActive: true, createdDate: new Date() }
];

const parentCategoryIds = db.categories.insertMany(parentCategories).insertedIds;

// Subcategorías
const subcategories = [
  { categoryName: "Camisetas", parentCategoryId: parentCategoryIds[0], ancestors: [parentCategoryIds[0]], description: "Camisetas y tops", isActive: true, createdDate: new Date() },
  { categoryName: "Pantalones", parentCategoryId: parentCategoryIds[0], ancestors: [parentCategoryIds[0]], description: "Pantalones y shorts", isActive: true, createdDate: new Date() },
  { categoryName: "Vestidos", parentCategoryId: parentCategoryIds[0], ancestors: [parentCategoryIds[0]], description: "Vestidos y faldas", isActive: true, createdDate: new Date() },
  { categoryName: "Abrigos", parentCategoryId: parentCategoryIds[0], ancestors: [parentCategoryIds[0]], description: "Abrigos y chaquetas", isActive: true, createdDate: new Date() },
  
  { categoryName: "Zapatillas", parentCategoryId: parentCategoryIds[1], ancestors: [parentCategoryIds[1]], description: "Zapatillas deportivas", isActive: true, createdDate: new Date() },
  { categoryName: "Zapatos", parentCategoryId: parentCategoryIds[1], ancestors: [parentCategoryIds[1]], description: "Zapatos formales", isActive: true, createdDate: new Date() },
  { categoryName: "Botas", parentCategoryId: parentCategoryIds[1], ancestors: [parentCategoryIds[1]], description: "Botas y botines", isActive: true, createdDate: new Date() },
  { categoryName: "Sandalias", parentCategoryId: parentCategoryIds[1], ancestors: [parentCategoryIds[1]], description: "Sandalias y chanclas", isActive: true, createdDate: new Date() },
  
  { categoryName: "Bolsos", parentCategoryId: parentCategoryIds[2], ancestors: [parentCategoryIds[2]], description: "Bolsos y mochilas", isActive: true, createdDate: new Date() },
  { categoryName: "Joyería", parentCategoryId: parentCategoryIds[2], ancestors: [parentCategoryIds[2]], description: "Collares, pulseras, anillos", isActive: true, createdDate: new Date() },
  { categoryName: "Cinturones", parentCategoryId: parentCategoryIds[2], ancestors: [parentCategoryIds[2]], description: "Cinturones y tirantes", isActive: true, createdDate: new Date() },
  { categoryName: "Gafas", parentCategoryId: parentCategoryIds[2], ancestors: [parentCategoryIds[2]], description: "Gafas de sol y vista", isActive: true, createdDate: new Date() },
  
  { categoryName: "Fútbol", parentCategoryId: parentCategoryIds[3], ancestors: [parentCategoryIds[3]], description: "Artículos de fútbol", isActive: true, createdDate: new Date() },
  { categoryName: "Running", parentCategoryId: parentCategoryIds[3], ancestors: [parentCategoryIds[3]], description: "Equipamiento para correr", isActive: true, createdDate: new Date() },
  { categoryName: "Natación", parentCategoryId: parentCategoryIds[3], ancestors: [parentCategoryIds[3]], description: "Artículos de natación", isActive: true, createdDate: new Date() },
  { categoryName: "Fitness", parentCategoryId: parentCategoryIds[3], ancestors: [parentCategoryIds[3]], description: "Equipamiento de gimnasio", isActive: true, createdDate: new Date() },
  
  { categoryName: "Decoración", parentCategoryId: parentCategoryIds[4], ancestors: [parentCategoryIds[4]], description: "Artículos decorativos", isActive: true, createdDate: new Date() },
  { categoryName: "Muebles", parentCategoryId: parentCategoryIds[4], ancestors: [parentCategoryIds[4]], description: "Muebles para el hogar", isActive: true, createdDate: new Date() },
  { categoryName: "Cocina", parentCategoryId: parentCategoryIds[4], ancestors: [parentCategoryIds[4]], description: "Utensilios de cocina", isActive: true, createdDate: new Date() },
  { categoryName: "Textil Hogar", parentCategoryId: parentCategoryIds[4], ancestors: [parentCategoryIds[4]], description: "Textiles para el hogar", isActive: true, createdDate: new Date() }
];

const subcategoryIds = db.categories.insertMany(subcategories).insertedIds;
print(`Insertadas ${parentCategories.length + subcategories.length} categorías`);

// Crear proveedores
const suppliers = [];
const supplierNames = [
  "Textiles Innovadores", "Calzados Premium", "Accesorios Globales", "Deportes Elite", 
  "Hogar Moderno", "Moda Actual", "Indumentaria Pro", "Distribuidora Estilo",
  "Proveedores Unidos", "Fashion Import", "Textiles del Sur", "Manufactura Deportiva",
  "Diseños Exclusivos", "Creaciones Urbanas", "Tendencia Global"
];

for (let i = 0; i < supplierNames.length; i++) {
  const cityId = randomItem(Object.values(cityIds));
  const cityIndex = Object.values(cityIds).findIndex(id => id.equals(cityId));
  const city = cities[cityIndex];
  
  suppliers.push({
    supplierName: supplierNames[i],
    contactName: `${randomItem(firstNames)} ${randomItem(lastNames)}`,
    contactEmail: `contacto@${supplierNames[i].toLowerCase().replace(/\s+/g, '')}.com`,
    contactPhone: `(${randomInt(100, 999)}) ${randomInt(100, 999)}-${randomInt(1000, 9999)}`,
    address: `Calle ${randomInt(1, 100)} #${randomInt(1, 999)}`,
    cityId: cityId,
    city: { cityName: city.cityName },
    taxId: `TX${randomInt(100000, 999999)}`,
    isActive: true,
    createdDate: new Date()
  });
}

const supplierIds = db.suppliers.insertMany(suppliers).insertedIds;
print(`Insertados ${suppliers.length} proveedores`);

// Crear productos
const products = [];
const productPrefixes = {
  "Camisetas": ["Camiseta", "Top", "Polo", "Blusa"],
  "Pantalones": ["Pantalón", "Jeans", "Short", "Bermuda"],
  "Vestidos": ["Vestido", "Falda", "Túnica", "Jumpsuit"],
  "Zapatillas": ["Zapatilla", "Sneaker", "Deportiva", "Runner"],
  "Zapatos": ["Zapato", "Mocasín", "Oxford", "Derby"],
  "Bolsos": ["Bolso", "Mochila", "Cartera", "Portafolio"],
  "Fútbol": ["Balón", "Espinillera", "Guante", "Camiseta"],
  "Decoración": ["Cuadro", "Jarrón", "Lámpara", "Alfombra"]
};

const allCategoryIds = {...parentCategoryIds, ...subcategoryIds};
const allCategories = [...parentCategories, ...subcategories];

for (let i = 0; i < 200; i++) {
  const categoryIndex = randomInt(0, allCategories.length - 1);
  const category = allCategories[categoryIndex];
  const categoryId = Object.values(allCategoryIds)[categoryIndex];
  
  const prefixes = productPrefixes[category.categoryName] || ["Producto"];
  const prefix = randomItem(prefixes);
  const brand = randomItem(["Brand X", "Premium", "Classic", "Urban", "Elite", "Natural", "Trendy", "Exclusive"]);
  
  const costPrice = randomInt(10, 100) * 10;
  const retailPrice = costPrice * (1 + randomInt(30, 100) / 100); // 30-100% margen
  
  products.push({
    productName: `${prefix} ${brand} ${randomInt(1000, 9999)}`,
    productCode: `PROD-${randomInt(10000, 99999)}`,
    sku: `SKU${randomInt(100000, 999999)}`,
    barcode: `BAR${randomInt(1000000, 9999999)}`,
    description: `${prefix} de alta calidad de la marca ${brand}, diseño moderno y confortable.`,
    categoryId: categoryId,
    category: { categoryName: category.categoryName },
    supplierId: randomItem(Object.values(supplierIds)),
    supplier: { supplierName: randomItem(supplierNames) },
    costPrice: costPrice,
    retailPrice: retailPrice,
    discountPrice: Math.random() > 0.7 ? retailPrice * (1 - randomInt(10, 30) / 100) : null, // 30% con descuento
    weight: randomInt(1, 50) / 10,
    dimensions: `${randomInt(10, 100)}x${randomInt(10, 100)}x${randomInt(5, 30)}`,
    isPerishable: false,
    minStockLevel: randomInt(5, 20),
    maxStockLevel: randomInt(50, 200),
    reorderPoint: randomInt(10, 30),
    priceHistory: [],
    isActive: true,
    createdDate: new Date()
  });
}

const productIds = db.products.insertMany(products).insertedIds;
print(`Insertados ${products.length} productos`);


// Crear inventario
const inventoryItems = [];

// Para cada tienda, agregar inventario de productos aleatorios
// Usando Object.entries para iterar sobre storeIds que es un objeto, no un array
Object.entries(storeIds).forEach(([index, storeId]) => {
  // Cada tienda tendrá entre 50 y 150 productos
  const storeIndex = parseInt(index);
  const store = stores[storeIndex];
  const numProducts = randomInt(50, 150);
  
  // Convertir productIds a array y seleccionar productos aleatorios
  const selectedProductIds = Object.values(productIds)
    .sort(() => 0.5 - Math.random())
    .slice(0, numProducts);
  
  selectedProductIds.forEach(productId => {
    // Encontrar el índice del producto en el array de productos
    const productIndex = Object.values(productIds).findIndex(id => id.equals(productId));
    const product = products[productIndex];
    
    inventoryItems.push({
      storeId: storeId,
      store: { storeName: store.storeName },
      productId: productId,
      product: { 
        productName: product.productName,
        sku: product.sku
      },
      quantityInStock: randomInt(product.minStockLevel, product.maxStockLevel),
      stockDate: new Date(),
      lastRestockDate: randomDate(new Date(2023, 0, 1), new Date()),
      createdDate: new Date()
    });
  });
});

// Insertar en lotes para evitar problemas con documentos muy grandes
const batchSize = 1000;
for (let i = 0; i < inventoryItems.length; i += batchSize) {
  const batch = inventoryItems.slice(i, i + batchSize);
  db.inventory.insertMany(batch, { ordered: false });
  print(`Insertados ${batch.length} registros de inventario (lote ${Math.floor(i/batchSize) + 1})`);
}

// Crear niveles de lealtad
const loyaltyLevels = [
  { levelName: "Bronce", minimumPoints: 0, discountPercentage: 0, otherBenefits: "Sin beneficios adicionales", isActive: true, createdDate: new Date() },
  { levelName: "Plata", minimumPoints: 1000, discountPercentage: 5, otherBenefits: "Envío gratis", isActive: true, createdDate: new Date() },
  { levelName: "Oro", minimumPoints: 5000, discountPercentage: 10, otherBenefits: "Envío gratis, promociones exclusivas", isActive: true, createdDate: new Date() },
  { levelName: "Platino", minimumPoints: 10000, discountPercentage: 15, otherBenefits: "Envío gratis, promociones exclusivas, atención preferencial", isActive: true, createdDate: new Date() }
];

const loyaltyLevelIds = db.loyaltyLevels.insertMany(loyaltyLevels).insertedIds;
print(`Insertados ${loyaltyLevels.length} niveles de lealtad`);

// Crear clientes
const customers = [];
for (let i = 0; i < 200; i++) {
  const firstName = randomItem(firstNames);
  const lastName = randomItem(lastNames);
  const cityId = randomItem(Object.values(cityIds));
  const cityIndex = Object.values(cityIds).findIndex(id => id.equals(cityId));
  const city = cities[cityIndex];
  
  // Asignar nivel de lealtad basado en puntos
  const loyaltyPoints = Math.random() > 0.7 ? randomInt(0, 15000) : 0;
  let loyaltyLevelId = loyaltyLevelIds[0]; // Nivel bronce por defecto
  let loyaltyLevel = loyaltyLevels[0];
  
  // Determinar nivel según puntos
  for (let l = loyaltyLevels.length - 1; l >= 0; l--) {
    if (loyaltyPoints >= loyaltyLevels[l].minimumPoints) {
      loyaltyLevelId = loyaltyLevelIds[l];
      loyaltyLevel = loyaltyLevels[l];
      break;
    }
  }
  
  customers.push({
    firstName: firstName,
    lastName: lastName,
    email: `${firstName.toLowerCase()}.${lastName.toLowerCase()}${randomInt(1, 999)}@email.com`,
    phone: `(${randomInt(100, 999)}) ${randomInt(100, 999)}-${randomInt(1000, 9999)}`,
    address: `Calle ${randomInt(1, 100)} #${randomInt(1, 999)}`,
    cityId: cityId,
    city: { cityName: city.cityName },
    loyaltyCardNumber: loyaltyPoints > 0 ? `CARD-${randomInt(10000, 99999)}` : null,
    loyaltyPoints: loyaltyPoints,
    loyaltyLevelId: loyaltyLevelId,
    loyaltyLevel: loyaltyLevel,
    birthDate: randomDate(new Date(1960, 0, 1), new Date(2005, 0, 1)),
    gender: randomItem(["M", "F"]),
    isActive: true,
    joinDate: randomDate(new Date(2015, 0, 1), new Date()),
    lastPurchaseDate: randomDate(new Date(2023, 0, 1), new Date()),
    purchaseHistory: [],
    createdDate: new Date()
  });
}

const customerIds = db.customers.insertMany(customers).insertedIds;
print(`Insertados ${customers.length} clientes`);

// Crear métodos de pago
const paymentMethods = [
  { methodName: "Efectivo", description: "Pago en efectivo", isActive: true, createdDate: new Date() },
  { methodName: "Tarjeta de Crédito", description: "Pago con tarjeta de crédito", isActive: true, createdDate: new Date() },
  { methodName: "Tarjeta de Débito", description: "Pago con tarjeta de débito", isActive: true, createdDate: new Date() },
  { methodName: "Transferencia", description: "Pago por transferencia bancaria", isActive: true, createdDate: new Date() },
  { methodName: "PayPal", description: "Pago por PayPal", isActive: true, createdDate: new Date() },
  { methodName: "Puntos de Lealtad", description: "Pago con puntos acumulados", isActive: true, createdDate: new Date() }
];

const paymentMethodIds = db.paymentMethods.insertMany(paymentMethods).insertedIds;
print(`Insertados ${paymentMethods.length} métodos de pago`);

// Crear promociones
const promotions = [
  { 
    promotionName: "Descuento de Temporada", 
    description: "Descuento de temporada en productos seleccionados", 
    startDate: new Date(2023, 0, 1), 
    endDate: new Date(2023, 11, 31), 
    discountType: "Percentage", 
    discountValue: 20, 
    minimumPurchase: 500, 
    products: [], 
    isActive: true, 
    createdDate: new Date() 
  },
  { 
    promotionName: "2x1 en Camisetas", 
    description: "Lleva 2 camisetas y paga 1", 
    startDate: new Date(2023, 3, 1), 
    endDate: new Date(2023, 5, 30), 
    discountType: "BuyXGetY", 
    discountValue: 100, 
    minimumPurchase: null, 
    products: [], 
    isActive: true, 
    createdDate: new Date() 
  },
  { 
    promotionName: "Descuento en Calzado", 
    description: "Descuento en toda la línea de calzado", 
    startDate: new Date(2023, 6, 1), 
    endDate: new Date(2023, 8, 30), 
    discountType: "Percentage", 
    discountValue: 15, 
    minimumPurchase: null, 
    products: [], 
    isActive: true, 
    createdDate: new Date() 
  },
  { 
    promotionName: "Oferta de Fin de Año", 
    description: "Descuentos especiales de fin de año", 
    startDate: new Date(2023, 11, 1), 
    endDate: new Date(2024, 0, 31), 
    discountType: "Percentage", 
    discountValue: 30, 
    minimumPurchase: 1000, 
    products: [], 
    isActive: true, 
    createdDate: new Date() 
  },
  { 
    promotionName: "Cupón de Descuento", 
    description: "Descuento fijo en tu compra", 
    startDate: new Date(2023, 5, 1), 
    endDate: new Date(2023, 7, 31), 
    discountType: "FixedAmount", 
    discountValue: 200, 
    minimumPurchase: 500, 
    products: [], 
    isActive: true, 
    createdDate: new Date() 
  }
];

// Asignar productos aleatorios a las promociones
promotions.forEach(promotion => {
  // Seleccionar entre 5 y 20 productos aleatorios
  const numProducts = randomInt(5, 20);
  const promoProducts = [];
  
  for (let i = 0; i < numProducts; i++) {
    promoProducts.push(randomItem(Object.values(productIds)));
  }
  
  promotion.products = promoProducts;
});

const promotionIds = db.promotions.insertMany(promotions).insertedIds;
print(`Insertadas ${promotions.length} promociones`);

// Crear ventas
const sales = [];
const saleDetails = [];

// Generar entre 500 y 1000 ventas
const numSales = randomInt(500, 1000);

for (let i = 0; i < numSales; i++) {
  // Seleccionar una tienda al azar
  const storeIndex = randomInt(0, stores.length - 1);
  const storeId = storeIds[storeIndex];
  const store = stores[storeIndex];
  
  // Seleccionar un empleado (cajero) de esa tienda
  const storeEmployees = employees.filter(emp => emp.storeId && emp.storeId.equals(storeId));
  const employee = storeEmployees.length > 0 ? randomItem(storeEmployees) : employees[0];
  const employeeId = employeeIds[employees.indexOf(employee)];
  
  // Decidir si la venta es de un cliente registrado o anónimo
  const hasCustomer = Math.random() > 0.3; // 70% de ventas con cliente registrado
  let customerId = null;
  let customer = null;
  
  if (hasCustomer) {
    const customerIndex = randomInt(0, customers.length - 1);
    customerId = customerIds[customerIndex];
    customer = customers[customerIndex];
  }
  
  // Fecha de venta en los últimos 2 años
  const saleDate = randomDate(new Date(2022, 0, 1), new Date());
  
  // Seleccionar método de pago
  const paymentMethodIndex = randomInt(0, paymentMethods.length - 1);
  const paymentMethodId = paymentMethodIds[paymentMethodIndex];
  const paymentMethod = paymentMethods[paymentMethodIndex];
  
  // Decidir si aplicar una promoción
  const hasPromotion = Math.random() > 0.7; // 30% de ventas con promoción
  let promotionId = null;
  let promotion = null;
  
  if (hasPromotion) {
    const promotionIndex = randomInt(0, promotions.length - 1);
    promotionId = promotionIds[promotionIndex];
    promotion = promotions[promotionIndex];
  }
  
  // Generar detalles de la venta (líneas)
  const items = [];
  const numItems = randomInt(1, 10); // Entre 1 y 10 productos por venta
  
  // Obtener inventario disponible en la tienda
  const storeInventory = inventoryItems.filter(inv => inv.storeId.equals(storeId));
  
  let subTotal = 0;
  let discountAmount = 0;
  
  for (let j = 0; j < numItems; j++) {
    if (storeInventory.length === 0) continue;
    
    // Seleccionar un producto del inventario
    const inventoryItem = randomItem(storeInventory);
    const productId = inventoryItem.productId;
    
    // Encontrar el producto en la lista de productos
    const productIndex = Object.values(productIds).findIndex(id => id.equals(productId));
    if (productIndex === -1) continue;
    
    const product = products[productIndex];
    
    // Determinar cantidad y precio
    const quantity = randomInt(1, 5);
    const unitPrice = product.discountPrice || product.retailPrice;
    const unitCost = product.costPrice;
    
    // Aplicar descuento adicional si hay promoción
    let discount = 0;
    if (hasPromotion && promotion.products.some(id => id.equals(productId))) {
      if (promotion.discountType === "Percentage") {
        discount = unitPrice * (promotion.discountValue / 100);
      } else if (promotion.discountType === "FixedAmount") {
        discount = promotion.discountValue / numItems; // Distribuir el descuento fijo
      }
    }
    
    const taxRate = 16; // 16% de IVA
    const taxAmount = (unitPrice - discount) * (taxRate / 100) * quantity;
    const lineTotal = (unitPrice - discount) * quantity + taxAmount;
    
    items.push({
      productId: productId,
      product: {
        productName: product.productName,
        sku: product.sku
      },
      quantity: quantity,
      unitPrice: unitPrice,
      unitCost: unitCost,
      discount: discount,
      taxRate: taxRate,
      taxAmount: taxAmount,
      lineTotal: lineTotal,
      returnedQuantity: 0,
      returnReason: null
    });
    
    subTotal += unitPrice * quantity;
    discountAmount += discount * quantity;
  }
  
  // Si no hay items, continuar con el siguiente ciclo
  if (items.length === 0) continue;
  
  const taxAmount = subTotal * 0.16; // 16% de IVA
  const totalAmount = subTotal - discountAmount + taxAmount;
  
  // Calcular puntos de lealtad (10 puntos por cada 100 de compra)
  const loyaltyPointsEarned = hasCustomer ? Math.floor(totalAmount / 100) * 10 : 0;
  
  // Crear el documento de venta
  const sale = {
    saleNumber: `SALE-${randomInt(100000, 999999)}`,
    storeId: storeId,
    store: { storeName: store.storeName },
    customerId: customerId,
    customer: hasCustomer ? {
      firstName: customer.firstName,
      lastName: customer.lastName,
      loyaltyCardNumber: customer.loyaltyCardNumber
    } : null,
    employeeId: employeeId,
    employee: {
      firstName: employee.firstName,
      lastName: employee.lastName
    },
    saleDate: saleDate,
    subTotal: subTotal,
    taxAmount: taxAmount,
    discountAmount: discountAmount,
    totalAmount: totalAmount,
    paymentMethodId: paymentMethodId,
    paymentMethod: { methodName: paymentMethod.methodName },
    paymentReference: paymentMethod.methodName === "Tarjeta de Crédito" || paymentMethod.methodName === "Tarjeta de Débito" 
      ? `REF-${randomInt(100000, 999999)}` 
      : null,
    loyaltyPointsEarned: loyaltyPointsEarned,
    promotionId: promotionId,
    promotion: hasPromotion ? { 
      promotionName: promotion.promotionName,
      discountType: promotion.discountType
    } : null,
    notes: null,
    status: Math.random() > 0.05 ? "Completed" : (Math.random() > 0.5 ? "Returned" : "Cancelled"),
    items: items,
    createdDate: new Date()
  };
  
  sales.push(sale);
}

const saleIds = db.sales.insertMany(sales).insertedIds;
print(`Insertadas ${sales.length} ventas con sus detalles`);

// Actualizar el historial de compras de los clientes
sales.forEach((sale, index) => {
  if (sale.customerId) {
    db.customers.updateOne(
      { _id: sale.customerId },
      { 
        $push: { purchaseHistory: saleIds[index] },
        $set: { lastPurchaseDate: sale.saleDate }
      }
    );
  }
});

print("Actualizado el historial de compras de los clientes");

// Crear algunas transacciones de inventario (compras, ventas, transferencias)
const inventoryTransactions = [];

// Transacciones de ventas (basadas en las ventas creadas)
sales.forEach((sale, index) => {
  if (sale.status === "Completed" || sale.status === "Returned") {
    sale.items.forEach(item => {
      inventoryTransactions.push({
        storeId: sale.storeId,
        store: sale.store,
        productId: item.productId,
        product: item.product,
        transactionType: "Sale",
        quantity: -item.quantity, // Negativo porque reduce el inventario
        transactionDate: sale.saleDate,
        sourceStoreId: null,
        employeeId: sale.employeeId,
        employee: sale.employee,
        saleId: saleIds[index],
        notes: `Venta #${sale.saleNumber}`,
        createdDate: new Date()
      });
    });
  }
});

// Transacciones de compra (reposición de inventario)
for (let i = 0; i < 200; i++) {
  const storeId = randomItem(Object.values(storeIds));
  const storeIndex = Object.values(storeIds).findIndex(id => id.equals(storeId));
  const store = stores[storeIndex];
  
  const productId = randomItem(Object.values(productIds));
  const productIndex = Object.values(productIds).findIndex(id => id.equals(productId));
  const product = products[productIndex];
  
  const employeeId = randomItem(Object.values(employeeIds));
  const employeeIndex = Object.values(employeeIds).findIndex(id => id.equals(employeeId));
  const employee = employees[employeeIndex];
  
  inventoryTransactions.push({
    storeId: storeId,
    store: { storeName: store.storeName },
    productId: productId,
    product: { 
      productName: product.productName,
      sku: product.sku
    },
    transactionType: "Purchase",
    quantity: randomInt(10, 100), // Positivo porque aumenta el inventario
    transactionDate: randomDate(new Date(2022, 0, 1), new Date()),
    sourceStoreId: null,
    employeeId: employeeId,
    employee: {
      firstName: employee.firstName,
      lastName: employee.lastName
    },
    purchaseOrderId: null,
    saleId: null,
    notes: "Reposición de inventario",
    createdDate: new Date()
  });
}

// Transacciones de transferencia entre tiendas
for (let i = 0; i < 50; i++) {
  // Seleccionar tienda origen y destino
  const sourceStoreIndex = randomInt(0, stores.length - 1);
  let targetStoreIndex;
  do {
    targetStoreIndex = randomInt(0, stores.length - 1);
  } while (targetStoreIndex === sourceStoreIndex);
  
  const sourceStoreId = storeIds[sourceStoreIndex];
  const sourceStore = stores[sourceStoreIndex];
  const targetStoreId = storeIds[targetStoreIndex];
  const targetStore = stores[targetStoreIndex];
  
  const productId = randomItem(Object.values(productIds));
  const productIndex = Object.values(productIds).findIndex(id => id.equals(productId));
  const product = products[productIndex];
  
  const employeeId = randomItem(Object.values(employeeIds));
  const employeeIndex = Object.values(employeeIds).findIndex(id => id.equals(employeeId));
  const employee = employees[employeeIndex];
  
  const quantity = randomInt(5, 30);
  const transactionDate = randomDate(new Date(2022, 0, 1), new Date());
  
  // Transacción de salida (origen)
  inventoryTransactions.push({
    storeId: sourceStoreId,
    store: { storeName: sourceStore.storeName },
    productId: productId,
    product: { 
      productName: product.productName,
      sku: product.sku
    },
    transactionType: "Transfer",
    quantity: -quantity, // Negativo porque sale de esta tienda
    transactionDate: transactionDate,
    sourceStoreId: null,
    employeeId: employeeId,
    employee: {
      firstName: employee.firstName,
      lastName: employee.lastName
    },
    purchaseOrderId: null,
    saleId: null,
    notes: `Transferencia a tienda ${targetStore.storeName}`,
    createdDate: new Date()
  });
  
  // Transacción de entrada (destino)
  inventoryTransactions.push({
    storeId: targetStoreId,
    store: { storeName: targetStore.storeName },
    productId: productId,
    product: { 
      productName: product.productName,
      sku: product.sku
    },
    transactionType: "Transfer",
    quantity: quantity, // Positivo porque entra a esta tienda
    transactionDate: transactionDate,
    sourceStoreId: sourceStoreId,
    sourceStore: { storeName: sourceStore.storeName },
    employeeId: employeeId,
    employee: {
      firstName: employee.firstName,
      lastName: employee.lastName
    },
    purchaseOrderId: null,
    saleId: null,
    notes: `Transferencia desde tienda ${sourceStore.storeName}`,
    createdDate: new Date()
  });
}

db.inventoryTransactions.insertMany(inventoryTransactions);
print(`Insertadas ${inventoryTransactions.length} transacciones de inventario`);

// Crear algunos registros de auditoría
const auditLogs = [];

// Cambios de precio
for (let i = 0; i < 50; i++) {
  const productId = randomItem(Object.values(productIds));
  const productIndex = Object.values(productIds).findIndex(id => id.equals(productId));
  const product = products[productIndex];
  
  const employeeId = randomItem(Object.values(employeeIds));
  const employeeIndex = Object.values(employeeIds).findIndex(id => id.equals(employeeId));
  const employee = employees[employeeIndex];
  
  const oldRetailPrice = product.retailPrice;
  const newRetailPrice = oldRetailPrice * (1 + (randomInt(-10, 20) / 100)); // -10% a +20%
  
  auditLogs.push({
    entityType: "Product",
    entityId: productId,
    action: "UPDATE",
    timestamp: randomDate(new Date(2022, 0, 1), new Date()),
    performedBy: `${employee.firstName} ${employee.lastName}`,
    oldValues: { 
      retailPrice: oldRetailPrice 
    },
    newValues: { 
      retailPrice: newRetailPrice 
    },
    reason: "Actualización de precio",
    ipAddress: `192.168.1.${randomInt(1, 255)}`
  });
}

// Cambios de empleados
for (let i = 0; i < 30; i++) {
  const employeeId = randomItem(Object.values(employeeIds));
  const employeeIndex = Object.values(employeeIds).findIndex(id => id.equals(employeeId));
  const employee = employees[employeeIndex];
  
  const adminEmployeeId = randomItem(Object.values(managerIds));
  const adminEmployeeIndex = Object.values(managerIds).findIndex(id => id.equals(adminEmployeeId));
  const adminEmployee = managers[adminEmployeeIndex];
  
  const oldSalary = employee.salary;
  const newSalary = oldSalary * (1 + (randomInt(5, 15) / 100)); // 5% a 15% de aumento
  
  auditLogs.push({
    entityType: "Employee",
    entityId: employeeId,
    action: "UPDATE",
    timestamp: randomDate(new Date(2022, 0, 1), new Date()),
    performedBy: `${adminEmployee.firstName} ${adminEmployee.lastName}`,
    oldValues: { 
      salary: oldSalary 
    },
    newValues: { 
      salary: newSalary 
    },
    reason: "Ajuste salarial",
    ipAddress: `192.168.1.${randomInt(1, 255)}`
  });
}

// Otros cambios diversos
for (let i = 0; i < 100; i++) {
  const entityTypes = ["Product", "Employee", "Store", "Customer", "Inventory"];
  const entityType = randomItem(entityTypes);
  
  let entityId;
  switch(entityType) {
    case "Product":
      entityId = randomItem(Object.values(productIds));
      break;
    case "Employee":
      entityId = randomItem(Object.values(employeeIds));
      break;
    case "Store":
      entityId = randomItem(Object.values(storeIds));
      break;
    case "Customer":
      entityId = randomItem(Object.values(customerIds));
      break;
    case "Inventory":
      entityId = null; // No hay ID directo para el inventario
      break;
  }
  
  const employeeId = randomItem(Object.values(employeeIds));
  const employeeIndex = Object.values(employeeIds).findIndex(id => id.equals(employeeId));
  const employee = employees[employeeIndex];
  
  auditLogs.push({
    entityType: entityType,
    entityId: entityId,
    action: randomItem(["INSERT", "UPDATE", "DELETE"]),
    timestamp: randomDate(new Date(2022, 0, 1), new Date()),
    performedBy: `${employee.firstName} ${employee.lastName}`,
    oldValues: {}, // Objetos vacíos para simplificar
    newValues: {},
    reason: randomItem([
      "Creación de registro", 
      "Actualización de datos", 
      "Borrado lógico", 
      "Mantenimiento del sistema",
      "Corrección de errores"
    ]),
    ipAddress: `192.168.1.${randomInt(1, 255)}`
  });
}

db.auditLogs.insertMany(auditLogs);
print(`Insertados ${auditLogs.length} registros de auditoría`);

// Crear registros de intentos de login
const loginAttempts = [];
const userNames = ["admin", "gerente", "supervisor", "vendedor", "contador", "almacen", "rrhh"];

for (let i = 0; i < 200; i++) {
  const userName = randomItem(userNames) + randomInt(1, 99);
  const success = Math.random() > 0.2; // 80% de logins exitosos
  
  loginAttempts.push({
    userName: userName,
    attemptDate: randomDate(new Date(2022, 0, 1), new Date()),
    successFlag: success,
    ipAddress: `192.168.1.${randomInt(1, 255)}`,
    userAgent: randomItem([
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15",
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0",
      "Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1"
    ]),
    failReason: !success ? randomItem([
      "Contraseña incorrecta",
      "Usuario no encontrado",
      "Cuenta bloqueada",
      "Sesión expirada"
    ]) : null
  });
}

db.loginAttempts.insertMany(loginAttempts);
print(`Insertados ${loginAttempts.length} intentos de login`);

print("\n==========================================");
print("¡Base de datos RetailChainDB poblada con éxito!");
print(`Resumen de datos creados:`);
print(`- ${countries.length} países`);
print(`- ${regions.length} regiones`);
print(`- ${cities.length} ciudades`);
print(`- ${stores.length} tiendas`);
print(`- ${employees.length + managers.length} empleados`);
print(`- ${products.length} productos`);
print(`- ${inventoryItems.length} registros de inventario`);
print(`- ${customers.length} clientes`);
print(`- ${sales.length} ventas`);
print(`- ${inventoryTransactions.length} transacciones de inventario`);
print(`- ${auditLogs.length} registros de auditoría`);
print(`- ${loginAttempts.length} intentos de login`);
print("==========================================");