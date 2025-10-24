# Parametrización EMK - JBE

Este repositorio contiene la configuración y personalización del sistema EMK para JBE.

## Estructura del Proyecto

```
# parametrizacion_emaku_jbe

## XML Table Column Reorganizer

### Overview

This Python script helps reorganize XML table formulas and column references when adding new columns to your EMAKU XML transaction files. It automatically updates:

- Column letter references in beanshell formulas
- `totales` attribute column lists
- `exportTotalCol` mappings
- Column comments and numbering
- Formula references to shifted columns

### Current Column Structure (from your XML)

Based on the analysis of your `JBTR00001_perfil.xml` file:

```
Position | Letter | Column Name        | Type
---------|--------|-------------------|----------
0        | a      | CODE              | DATASEARCH
1        | b      | DESCRIPCION       | STRING
2        | c      | CANTIDAD          | INTEGER
3        | d      | Lista             | INTEGER
4        | e      | VUNITARIO         | DECIMAL
5        | f      | PIVA              | DECIMAL
6        | g      | PDCTO             | DECIMAL
7        | h      | STOTAL            | DECIMAL
8        | i      | DESCUENTO         | DECIMAL
9        | j      | NETO              | DECIMAL
10       | k      | TIVA              | DECIMAL
11       | l      | TOTAL             | DECIMAL
12       | m      | ID                | STRING
...      | ...    | ...               | ...
```

### Key Formulas That Will Be Updated

The script automatically handles these formula types:

#### Beanshell Formulas
```xml
<!-- Example formulas that reference columns by letter -->
<arg attribute="beanshell">h=al<0?(c*e)/(1+(f/100.0)):((e-(am*(al/100.0)))*c)/(1+(f/100.0))</arg>
<arg attribute="beanshell">j=al<0?(c*e-i)/(1+(f/100.0)):(((e-(am*(al/100.0)))*c)-i)/(1+(f/100.0))</arg>
```

#### Formula Attributes
```xml
<arg attribute="formula">i=((c*e)*g/100.0)</arg>
<arg attribute="formula">l=(c*e)-i</arg>
```

#### Totales Configuration
```xml
<arg attribute="totales">c,h,i,j,k,l,q,s,t,u,v,w,x,y,z,aa,ab,an</arg>
```

#### Export Total Columns
```xml
<arg attribute="exportTotalCol">c,totalcantidades</arg>
<arg attribute="exportTotalCol">h,stotal</arg>
```

### Usage

#### 1. Basic Command Line Usage

```bash
# Preview changes only
python column_reorganizer.py your_file.xml 5 preview

# Interactive mode
python column_reorganizer.py your_file.xml
```

#### 2. Programmatic Usage

```python
from column_reorganizer import ColumnReorganizer

# Initialize
reorganizer = ColumnReorganizer("your_file.xml")

# Preview what would change
preview = reorganizer.preview_changes(insert_position=5)

# Configure new column
new_column = {
    'name': 'NEW_CALC',
    'length': '90',
    'type': 'DECIMAL',
    'enabled': 'false',
    'roundDecimal': '2'
}

# Insert column and update all references
success = reorganizer.insert_column(5, new_column)
```

#### 3. Interactive Example Mode

```bash
python example_usage.py
```

### What Happens When You Insert a Column

#### Example: Inserting at Position 5 (between 'e' and 'f')

**Before:**
- Position 5: `f` (PIVA)
- Position 6: `g` (PDCTO)
- Position 7: `h` (STOTAL)

**After:**
- Position 5: `f` (NEW_COLUMN)
- Position 6: `g` (PIVA) - shifted from old 'f'
- Position 7: `h` (PDCTO) - shifted from old 'g'
- Position 8: `i` (STOTAL) - shifted from old 'h'

**Formula Updates:**
```
Original: h=al<0?(c*e)/(1+(f/100.0))
Updated:  i=al<0?(c*e)/(1+(g/100.0))
          ^                 ^
          h->i              f->g
```

### Safety Features

1. **Preview Mode**: See all changes before applying them
2. **Backup Recommendation**: Always backup your XML files first
3. **Validation**: Checks for valid column positions and mappings
4. **Error Handling**: Graceful handling of edge cases

### Configuration Options for New Columns

When adding a new column, you can specify:

```python
{
    'name': 'COLUMN_NAME',        # Required
    'length': '80',               # Display width
    'type': 'DECIMAL',           # STRING, DECIMAL, INTEGER
    'enabled': 'true',           # true/false
    'roundDecimal': '2',         # For DECIMAL types
    'queryCol': '50',            # Database query column
    'returnCol': '15',           # Return column mapping
    'printable': 'true',         # Include in reports
    'defaultValue': '0',         # Default value
    'minValue': '0'              # Minimum value
}
```

### Common Use Cases

#### 1. Adding a New Calculation Column
```python
calc_column = {
    'name': 'MARGIN',
    'type': 'DECIMAL',
    'enabled': 'false',
    'roundDecimal': '2'
}
reorganizer.insert_column(12, calc_column)  # After TOTAL
```

#### 2. Adding a New Data Field
```python
data_column = {
    'name': 'CATEGORY',
    'type': 'STRING',
    'length': '100',
    'enabled': 'false',
    'queryCol': '55'
}
reorganizer.insert_column(15, data_column)
```

### Important Notes

⚠️ **Before Running:**
1. **Backup your XML files**
2. Test with a copy first
3. Verify the insertion position is correct

⚠️ **After Running:**
1. Check all formulas are working correctly
2. Verify totales calculations
3. Test the application functionality

### Troubleshooting

**Q: Formula references are incorrect after insertion**
A: Check that the insertion position was correct and run preview mode first

**Q: Some columns weren't shifted**
A: The script updates references within the table component. Manual formulas outside may need updates

**Q: Getting "out of range" errors**
A: The column alphabet has limits. Check if you're inserting beyond supported range
├── transacciones/       # Definiciones de formularios (XML)
├── sentencias_sql/      # Consultas SQL
├── templates/           # Plantillas
├── database/            # Configuración de base de datos
│   ├── migrations/      # Migraciones de esquema
│   └── seeds/           # Datos iniciales
├── resources/           # Recursos
│   ├── jar_files/       # Bibliotecas Java
|   |   |── server_side/ # jars del lado del servidor /usr/local/emaku
    |   |── client_side/ # jars del lado del cliente /var/www/html/emaku
│   └── icons/           # Íconos de la aplicación
├── docs/                # Documentación adicional
└── .github/workflows/   # Flujos de trabajo de GitHub Actions
```

## Requisitos

- PostgreSQL
- Java (versión compatible con EMK)
- Cliente Git

## Configuración Inicial

1. Clonar el repositorio
2. Configurar la base de datos
3. Importar las transacciones y sentencias SQL

## Guía de Contribución

1. Crear una rama para cada nueva característica
2. Usar mensajes de commit descriptivos
3. Hacer pull request a la rama principal
