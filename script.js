const fs = require('fs');
const path = require('path');

// Folder structure definition
const folderStructure = {
  'docs': 'Documentación del proyecto',
  'docs/diagrams': 'Diagramas ER, arquitectura y modelado',
  'docs/requirements': 'Documentos de requisitos y especificaciones',
  
  'sql-server': 'Componentes de SQL Server',
  'sql-server/schema': 'Scripts de creación de tablas y estructura de la base de datos',
  'sql-server/data': 'Scripts para poblar la base de datos con datos de prueba',
  'sql-server/queries': 'Las 8 consultas complejas requeridas por el proyecto',
  'sql-server/stored-procedures': 'Procedimientos almacenados para operaciones frecuentes',
  'sql-server/functions': 'Funciones escalares y de tabla',
  'sql-server/triggers': 'Scripts de triggers para auditoría, validación y actualización en cascada',
  'sql-server/indexes': 'Scripts de creación y configuración de índices',
  'sql-server/transactions': 'Scripts de demostración de transacciones y niveles de aislamiento',
  'sql-server/distributed': 'Configuración de servidores vinculados y consultas distribuidas',
  
  'nosql': 'Componente de base de datos NoSQL',
  'nosql/schema': 'Estructura de documentos y colecciones',
  'nosql/data': 'Datos de muestra para la base NoSQL',
  'nosql/queries': 'Consultas y operaciones NoSQL',
  
  'integration': 'Scripts para la integración entre SQL Server y NoSQL',
  
  'optimization': 'Análisis de rendimiento y optimización',
  'optimization/execution-plans': 'Planes de ejecución y análisis de rendimiento',
  'optimization/benchmarks': 'Resultados de pruebas de rendimiento y comparativas',
  
  'team': 'Documentos relacionados con el trabajo en equipo',
  'team/evaluations': 'Plantillas y resultados de evaluación del trabajo en equipo'
};

// Main README content
const mainReadmeContent = `# Sistema de Gestión para Cadena Minorista

Proyecto final de Base de Datos Avanzadas (ITLA). Implementación SQL Server + NoSQL con consultas complejas, procedimientos, triggers y arquitectura distribuida.

## Estructura del Proyecto

- **docs/**: Documentación, diagramas y requisitos
- **sql-server/**: Componentes de SQL Server
- **nosql/**: Componente de base de datos NoSQL
- **integration/**: Integración entre SQL Server y NoSQL
- **optimization/**: Análisis de rendimiento y optimización
- **team/**: Documentos relacionados con el trabajo en equipo

## Requisitos

- SQL Server
- MongoDB/CosmosDB

## Miembros del Equipo

- [Miembro 1]
- [Miembro 2]
- [Miembro 3]
- [Miembro 4]
`;

// Create main README
fs.writeFileSync('README.md', mainReadmeContent);
console.log('Created main README.md');

// Create folders and READMEs
for (const [folderPath, description] of Object.entries(folderStructure)) {
  // Create folder if not exists
  if (!fs.existsSync(folderPath)) {
    fs.mkdirSync(folderPath, { recursive: true });
  }

  const folderName = path.basename(folderPath);
  
  // Create README content
  const readmeContent = `# ${folderName.charAt(0).toUpperCase() + folderName.slice(1).replace(/-/g, ' ')}

${description}
`;

  fs.writeFileSync(path.join(folderPath, 'README.md'), readmeContent);
  console.log(`Created README in: ${folderPath}`);
}

console.log('All folders and README files created.');