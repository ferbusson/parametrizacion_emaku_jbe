# Lista de Verificación para Despliegue de Emaku

## 1. Información que debe estar lista en Emaku

### 1.1. Migración de Productos

#### 1.1.1. Limpieza de Datos
- [ ] Eliminar repetidos: (ref_proveedor, descripcion, cod_sap)
- [ ] Para los que no tienen SAP: Eliminar repetidos: (ref_proveedor, descripcion)

#### 1.1.2. Configuración de Productos
- [ ] Migrar listado completo de productos
- [ ] El código de barras de las pinturas es el que está en el catálogo
- [ ] Si la pintura no está en el catálogo usar el SAP como código de barras
- [ ] Hacer que el cod SAP sea la referencia de las pinturas
- [ ] La ref_proveedor es el código en los que no tienen cod_sap
- [ ] Las referencias de los productos que no son pinturas siguen siendo las mismas
- [ ] Para facilitar la búsqueda de las pinturas agregar la referencia actual a la descripción
- [ ] Migrar precios de venta
- [ ] Para la lista 6 de precios base usar la fórmula que se tiene de la reunión con Jairo

### 1.2. Migración de Terceros (Clientes, Proveedores, etc)
- [ ] Migración de usuarios de sistema (Hecho)
- [ ] Migrar terceros relevantes (cartera, proveedores, fondos de pensiones, CCF, ips, eps, etc)


### 1.3. Migración de Saldos Iniciales
- [ ] Migrar saldos iniciales saldos inventario
  - [ ] Hacerlo por producto y bodega
- [ ] Migrar cartera pendiente CxC
- [ ] Migrar cuentas por pagar CxP
- [ ] Migrar saldos de anticipos hechos por clientes
- [ ] Migrar saldos puntos (si los hay)
- [ ] Migrar saldos iniciales contabilidad

---

## 2. Opciones del Programa que Deben Estar Listas

### 2.1. Terceros
- [ ] Nuevo Tercero
- [ ] Nuevo Tercero Cajas
- [ ] Nuevo Tercero Rápido
- [ ] Editar
- [ ] Borrar
- [ ] Consultar
- [ ] Consultar Terceros WS DIAN
- [ ] Cambio de terceros a Documentos
### 2.2. Productos

#### 2.2.1. Artículos
- [ ] Nuevo Item con barra autogenerada
- [ ] Nuevo Item con barra manual
- [ ] Editar producto completo
- [ ] Editar Pventa y Costo
- [ ] Editar Pventa y Costo Masivo según agrupación JBE *
- [ ] Borrar
- [ ] Corregir código errado
- [ ] Desactivar productos desde Excel

#### 2.2.2. Marcas
- [ ] Nuevo
- [ ] Editar
- [ ] Borrar
- [ ] Consultar proveedores Marca

#### 2.2.3. Configuraciones Generales
- [ ] Admin de Submarcas
- [ ] Grupos de Colores
- [ ] Colores
- [ ] Presentación
- [ ] Tallas
- [ ] Rango de Tallas
- [ ] TRM
- [ ] Transportadora
- [ ] Catálogo precios de venta
- [ ] Unidades de venta
- [ ] Administración de grupos
- [ ] Asientos Contables
- [ ] *Consultar producto
- [ ] Maestro de Productos

#### 2.2.4. Reportes
- [ ] Reporte productos x Clasificación
- [ ] Listado de Precios de venta
### 2.3. Ventas

#### 2.3.1. Facturación
- [ ] Promociones
- [ ] Factura Electrónica (Ventas Contado y Crédito)
- [ ] Factura de Contingencia (Ventas Contado y Crédito)
- [ ] Pedidos
- [ ] Cotizaciones
- [ ] **Devoluciones en Venta**
  - [ ] Con factura
  - [ ] Sin factura
- [ ] Activación de Pedidos y Cotizaciones
- [ ] Resolución de Facturación
- [ ] Envío Facturas E Web Service DIAN
- [ ] Abonos a Cartera (CxC) (facturas crédito)

#### 2.3.2. Reportes
- [ ] Reportes de Ventas
- [ ] Reportes de Carteraón
            Envio Facturas E Web Service DIAN
            Abonos a Cartera (CxC) (facturas credito)
            Reportes:
### 2.4. Compras
- [ ] Entradas Almacén (Compras)
- [ ] Devolución en Compras
- [ ] Pagos a Proveedores
- [ ] Documento Soporte en Compras ?
- [ ] Devolución Documento Soporte en Compras
- [ ] Despacho Devolución en Compras
- [ ] Importar productos desde Excel
- [ ] Importar Plantilla de Compras
- [ ] Importar Productos Nuevos sin Barra

#### 2.4.1. Reportes Entradas Almacén
- [ ] Reporte Entradas almacén por fecha y terceros
- [ ] Reporte Entradas almacén detallado por productos
- [ ] Reporte Entradas almacén y traslados

#### 2.4.2. Reporte Pagos a Proveedores (CxP)
- [ ] Reporte de CxP Pendiente y traslados
        Reporte Pagos a Proveedores (CxP)
### 2.5. Comprobantes
- [ ] Anticipos de Facturación
- [ ] Documento Soporte en Gastos

#### 2.5.1. Reportes
### 2.6. Nómina

#### 2.6.1. Conceptos Causación
- [ ] NUEVO
- [ ] EDITAR
- [ ] CONSULTAR
- [ ] **Informes**
  - [ ] Reporte General de Conceptos Causación

#### 2.6.2. Novedades Nómina
- [ ] NUEVO
- [ ] Editar
- [ ] ANULAR
- [ ] CONSULTAR
- [ ] **Informes**
  - [ ] Informe Novedades Nómina por Fecha y Tercero

#### 2.6.3. Registro Conceptos Nómina por Valor
- [ ] NUEVO
- [ ] Editar
- [ ] ANULAR
- [ ] CONSULTAR
- [ ] **Informes**
  - [ ] Informe Conceptos Nómina por Valor | Por Fecha y División

#### 2.6.4. Importación de Extras y Recargos
- [ ] NUEVO
- [ ] ANULAR
- [ ] CONSULTAR

#### 2.6.5. Generación de XML Nómina Electrónica
- [ ] NUEVO
- [ ] CONSULTAR

#### 2.6.6. Nómina Electrónica
- [ ] Nómina Electrónica Ajuste
- [ ] Nómina Electrónica Eliminar

#### 2.6.7. Administración Causación
- [ ] POR_EMPLEADO
- [ ] COMUNES
- [ ] Trasladar Conceptos Causación
- [ ] Administración de Divisiones
- [ ] POR_EMPLEADO

#### 2.6.8. División Empresarial
- [ ] NUEVO
- [ ] EDITAR
- [ ] BORRAR

#### 2.6.9. Causación Nómina
- [ ] NUEVO
- [ ] ANULAR
- [ ] CONSULTAR
- [ ] Temporal Nómina

#### 2.6.10. Causación CxC Empleados
- [ ] NUEVO
- [ ] ANULAR
- [ ] CONSULTAR
- [ ] REPORTES
- [ ] Informe Causación CxC Empleados
### 2.7. Notas

#### 2.7.1. Nota Multiregistro
- [ ] Nuevo
- [ ] Editar
- [ ] Anular
- [ ] Consultar

### 2.8. Arqueo

#### 2.8.1. Arqueo Caja
- [ ] Nuevo
- [ ] Editar
- [ ] Anular
- [ ] Consultar

#### 2.8.2. Operaciones de Caja
- [ ] Ventas del Día
- [ ] Consultar Arqueos Caja (Revisión de faltantes sobrantes)

#### 2.8.3. Informe Diario de Facturación
### 2.9. Contabilidad

#### 2.9.1. Reportes Administrativos
- [ ] Ventas del Día
- [ ] Reporte detallado ventas

#### 2.9.2. Configuraciones Generales
- [ ] Administración de Cuentas
- [ ] Administración Tipo Documento
- [ ] Administración Centro de Costo
- [ ] Grupos de Impuestos
- [ ] Asientos predefinidos
- [ ] Documento de Cierre

#### 2.9.3. Informes Contables

##### 2.9.3.1. Estados Financieros
- [ ] Libro Mayor y Balance
- [ ] Libro Diario por Rango de Fechas
- [ ] Balance General
- [ ] Libro Inventarios y Balances
- [ ] Estado de Resultados

##### 2.9.3.2. Informes de Contabilidad
- [ ] Balance de Comprobación
- [ ] Balance por Terceros
- [ ] Balance por Terceros con Corte por Año
- [ ] Balance detallado de Terceros
- [ ] Contabilización de Documentos
- [ ] Registro de documentos por fecha
- [ ] Reporte detallado de libros auxiliares
- [ ] Reporte detallado de auxiliares por cuenta
- [ ] Reporte resumido de libros auxiliares
- [ ] Reporte resumido de auxiliares por cuenta
- [ ] Numeración de libros oficiales

##### 2.9.3.3. Informe de Impuestos
- [ ] Reporte General de Impuestos
- [ ] Reporte de IVA compras contado
- [ ] Reporte de IVA compras crédito
### 2.10. Kardex

#### 2.10.1. Operaciones Básicas
- [ ] Consultar Bodegas

#### 2.10.2. Traslados
- [ ] Multisucursal
- [ ] Entradas Almacén

#### 2.10.3. Informes de Traslados
- [ ] Informe traslados por Sucursal y Fechas
- [ ] Informe traslados detallado por proveedor, sucursal y fecha

#### 2.10.4. Ajustes de Inventarios
- [ ] Ajuste Inventarios - Fragmentación
- [ ] Ajuste Inventarios - Composición
- [ ] Ajuste General Inventarios
- [ ] Conteos Inventario

#### 2.10.5. Informes de Inventarios
- [ ] Reporte extendido de Productos
- [ ] Reporte final inventario desglosado - Tercero y Marca
- [ ] Reporte final inventario desglosado - Línea y Grupo
                Numeracion de libros oficiales
            Informe de Impuestos
                Reporte General de Impuestos
                Reporte de IVA compras contado
                Reporte de IVA compras crédito
                Reporte de IVA en gastos
                Reporte de IVA generado
                Certificados de Retencion en la Fuente
                Listado de Certificados de Retencion en la Fuente
            Informes de Auditoria
                Reporte de Elaboracion de Documentos por Usuario Sistema
    Kardex
        Consultar Bodegas
        Traslados
            Multisucursal
            Entradas Almacen
        Informes
            Informe traslados por Sucursal Y Fechas
            Informe traslados detallado por proveedor, sucursal y fecha
        Ajuste Inventarios - Fragmentacion
        Ajuste Inventarios - Composicion
        Ajuste General Inventarios
        Conteos Inventario
        Informes de Inventarios
            Reporte exendido de Productos
            Reporte final inventario desglosado - Tercero y Marca
            Reporte final inventario desglosado - Linea y Grupo