# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the parametrization repository for the **EMAKU** ERP system, customized for **JBE** (a paint/hardware retailer with multiple branches). EMAKU is a Java-based ERP that is configured through XML form definitions and SQL queries stored in the database. This repo contains those configurations — not the EMAKU platform source code itself.

These are a collection of XML files used to represent forms in a java app, the app is intended to  
  be an ERP used in retail sales businesses, the structure of the folders mimics the menu in the app,      
  each file contains components and labels that are rendered by the java core, each component has been    
  developed to do specific actions, some of the common components are layouts, tables, text fields, these are implementations of java components represented as XML components with attributes related to available attributes in java.

## Architecture

### How EMAKU Works

EMAKU forms are defined by two paired XML files per transaction:
- `*_perfil.xml` — the form layout (components, drivers, BeanShell formulas, column definitions)
- `*_args_driver.xml` — the arguments/parameters passed to the form's driver

SQL queries are stored in the EMAKU database (`sentencia_sql` table) and referenced by ID (e.g., `JBSEL0062`). The SQL files in this repo are the source of truth; after editing, they must be loaded into the database via EMAKU's "Recarga de Transacciones y Sentencias" function.

Printing templates (`TN*.xml` = used in forms that create documents in the database this differ from the View forms -> `TS*.xml` Creation forms take the number from the java program because multiple users can have the same form displayed so the first that clicks on Save button will get the current available consecutive. The view doesn't need this info from the app, the user look up the document by the number manually typed). The printing format is defined by the dimensions and the drivers defined in each template 

### Naming Conventions

The SQL codes are arbitrary in the prefix, it usually lets the developer to create queries according to the database name, what is more important are the SEL, UPD, DEL AND INS part of the name that shows the nature of the query. The numeric part is the consecutive for each query.


### Directory Structure

```
transacciones/          # Form definitions organized by business module
  ventas/               # Sales: pedidos, cotizaciones, facturas, devoluciones, cartera
  compras/              # Purchasing: entradas_almacen, pagos_a_proveedores, doc_soporte
  productos/            # Product master, price updates, inventory
  nomina/               # Payroll
  kardex/               # Inventory transfers and adjustments
  arqueo/               # Cash register reconciliation
  configuracion/        # System configuration forms
  ...
database/
  migrations/           # Schema changes and one-off SQL scripts
  seeds/                # Initial data
resources/
  jar_files/
    server_side/        # JARs deployed to /usr/local/emaku
    client_side/        # JARs deployed to /var/www/html/emaku
  icons/                # Application icons
docs/
  manuals/sales/        # JBTR00001–JBTR00011 form manuals
  pendientes.md         # Pending tasks and business notes
```

### Key Business Flows

**Sales chain:** Cotización → Pedido → Factura Electrónica (Contado or Crédito)
- `rf_documento` in `info_documento` links each document to its related document
- Cancellation must check that no active downstream document exists

**Branches (sucursales):**
- Z1 PRINCIPAL, Z2 CARRERA 21, Z3 CASA DEL CARPINTERO, Z4 AMERICAS, Z5 ICO, Z6 SIKA, Z7 CARPINTERO CENTRO

**Electronic invoicing (factura electrónica):** Colombian DIAN e-invoicing is integrated. XML structure matters — `cac:OrderReference` links invoices to orders.

**JaviPuntos:** Loyalty points system with its own tables (`puntos_tercero`); trigger-based accumulation logic in `database/migrations/calcular_saldo_acumulado_puntos_y_trigger.sql`.

## Working with XML Forms

### Column References in Table Components

Table columns use alphabetic identifiers (`a`, `b`, `c`, ... `z`, `aa`, `ab`, ...). BeanShell formulas, `totales` attributes, and `exportTotalCol` all reference these letters. When inserting or removing a column, all downstream letter references must be updated.

Use the helper script to preview and apply shifts:
```bash
# Preview what would change when inserting a column at position N
python column_reorganizer.py transacciones/ventas/pedidos/xml/JBTR00001_perfil.xml <N> preview

# Apply the changes
python column_reorganizer.py transacciones/ventas/pedidos/xml/JBTR00001_perfil.xml <N>
```

Always back up the XML file before running this script.

### Deploying Changes

1. **XML forms**: Upload via EMAKU's "Recarga de Transacciones y Sentencias" admin panel
2. **SQL queries**: Load into the `sentencia_sql` table via the same reload function
3. **JARs (server)**: Copy to `/usr/local/emaku`
4. **JARs (client)**: Copy to `/var/www/html/emaku`
5. **Printing templates**: Upload through EMAKU's template management

## Database

PostgreSQL. Key tables referenced frequently:
- `sentencia_sql` — stores all SQL queries by ID
- `documentos_standar` — document type definitions
- `info_documento` — document metadata including `rf_documento` (parent link)
- `puntos_tercero` — loyalty points balances

Schema changes are documented in `database/migrations/cambios_hechos_en_tablas.sql`.

## Python Utilities

The repo includes helper scripts (require the `venv`):

```bash
source venv/bin/activate

# Reorganize XML column references after adding a column
python column_reorganizer.py <xml_file> <insert_position> [preview]

# Quick test of column_reorganizer
python quick_test.py

# Generate/update form manuals from XML
python3 docs/manuals/generate_manuals.py

# Interactive manual management
python3 docs/manuals/manage_manuals.py interactive

# Check manual completion status
python3 docs/manuals/manage_manuals.py status
```

## Important Context

- The business context is a Colombian paint/hardware retailer; tax handling follows Colombian DIAN rules (IVA, retenciones, factura electrónica)
- Price lists: multiple lists exist (e.g., lista 6 for base price), list selection is per-customer
- Pending work is tracked in `docs/pendientes.md`
- Deployment checklist is at `docs/manuals/check_list_deployment.md`