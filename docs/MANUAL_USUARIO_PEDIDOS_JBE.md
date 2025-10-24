# Manual de Usuario - Sistema de Pedidos de Mostrador JBE

## Descripción General

Este formulario permite generar pedidos de mostrador con configuración especial para JBE, proporcionando una interfaz completa para la gestión de pedidos que se integra con el proceso de facturación electrónica.

## Características Principales

### ✅ Funcionalidades Implementadas

- **Generación de pedidos de mostrador** con configuración especial para JBE
- **Datos del cliente obligatorios** - El sistema solicita información completa del cliente
- **Correo electrónico obligatorio** - Necesario para el proceso de facturación electrónica posterior
- **Asignación automática de correo** - Si el tercero no tiene correo, el sistema asigna el correo por defecto de configuración
- **Búsqueda avanzada de productos** - Múltiples métodos de búsqueda
- **Sistema de listas de precios** - Manejo automático según el cliente
- **Descuentos automáticos** - Aplicación de promociones vigentes
- **Cálculos automáticos** - Impuestos y totales se calculan en tiempo real
- **Gestión de vigencia** - Control de validez del pedido
- **Vendedor asignable** - Selección del vendedor responsable
- **Información externa** - Número de orden del cliente
- **Observaciones** - Espacio para fórmulas e información adicional
- **Datos de entrega** - Dirección y teléfono de contacto
- **Sistema de puntos** - Enlace con pintor, constructor o carpintero
- **Guardado temporal** - Para pedidos largos que requieren varias sesiones
- **Recuperación de temporales** - Continuar con pedidos guardados previamente

## Estructura del Formulario

### 1. Información del Cliente (Pestaña "THIRD")

#### Búsqueda de Tercero
- **Campo principal**: Búsqueda de cliente por NIT/CC o nombre
- **Búsqueda inteligente**: El sistema muestra sugerencias mientras escribe
- **Límite de registros**: Máximo 100 resultados para optimizar rendimiento
- **Información automática**: Al seleccionar cliente se cargan automáticamente:
  - Dirección principal
  - Teléfono principal  
  - Correo electrónico
  - Lista de precios aplicable
  - Descuentos vigentes

#### Datos Automáticos del Cliente
- **Dirección**: Se muestra la dirección principal registrada
- **Teléfono**: Número de contacto principal
- **Email**: Correo electrónico (obligatorio para facturación electrónica)
- **Estado empleado**: Indica si el tercero es empleado de la empresa

### 2. Generación de Documento (Pestaña "GENERAR")

#### Configuración del Documento
- **Tipo de documento**: Selección del tipo de pedido a generar
- **Número generador**: Se asigna automáticamente el número secuencial

### 3. Sistema de Puntos (Pestaña "Javipuntos")

#### Asociación de Referidores
- **Pintor/Carpintero/Constructor**: Campo para enlazar el pedido con el profesional referidor
- **Búsqueda por NIT/CC**: Sistema de búsqueda para localizar al referidor
- **Nombre automático**: Se muestra el nombre del referidor seleccionado
- **Plan de puntos**: Esta información se usa para el sistema de puntos de la empresa

### 4. Información del Pedido

#### Datos Generales
- **Fecha**: Se asigna automáticamente la fecha actual
- **Vigencia**: Por defecto 1 día, modificable por el usuario
- **Fecha de vencimiento**: Se calcula automáticamente (fecha + vigencia)
- **Vendedor**: Selección del vendedor responsable del pedido
- **Número de orden**: Campo para ingresar número de orden externa del cliente
- **Email**: Correo del cliente (requerido para facturación electrónica)

### 5. Tabla de Productos (Pestaña "Pedido")

#### Sistema de Listas de Precios
- **Lista 1 (Carta)**: Lista por defecto
- **Lista 2 (Abanico)**: Depende del cliente seleccionado  
- **Lista 3 (Bases)**: Depende del cliente seleccionado

#### Búsqueda de Productos
- **F2**: Búsqueda por código de barras, código alterno y descripción
- **Código directo**: Digite directamente el código de barras
- **Lector de código**: Compatible con lectores de código de barras
- **Búsqueda inteligente**: Sistema de sugerencias en tiempo real

#### Columnas de la Tabla
1. **CODE**: Código del producto (búsqueda inteligente)
2. **DESCRIPCIÓN**: Nombre del producto (se llena automáticamente)
3. **Disp**: Disponibilidad en inventario
4. **Cant**: Cantidad (solo números enteros, no decimales)
5. **Lista**: Tipo de lista de precios (1, 2 o 3)
6. **VUNITARIO**: Valor unitario según la lista seleccionada
7. **PIVA**: Porcentaje de IVA del producto
8. **PDCTO**: Porcentaje de descuento aplicable
9. **STOTAL**: Subtotal de la línea
10. **DESCUENTO**: Valor del descuento aplicado
11. **NETO**: Valor neto (sin IVA)
12. **TIVA**: Valor del IVA
13. **TOTAL**: Total de la línea

#### Cálculos Automáticos
- **Descuentos por cliente**: Se aplican automáticamente si el producto está en promociones vigentes
- **Impuestos**: Se calculan automáticamente según configuración del producto
- **Totales**: Sumatoria automática de todas las líneas
- **Impuesto verde**: Cálculo automático para productos con bolsas

### 6. Gestión de Temporales (Pestaña "Temporales")

#### Guardado Temporal
- **Propósito**: Para pedidos largos que requieren varias sesiones
- **Selección**: Combo con pedidos temporales guardados
- **Recuperación**: Cargar pedido temporal para continuar elaboración
- **Total cantidad**: Muestra el total de productos en el temporal

### 7. Totales y Resúmenes

#### Panel de Totales
- **Aplicar % Desc**: Campo para aplicar descuento global adicional
- **STOTAL**: Subtotal general
- **TDCTO**: Total descuentos
- **NETO**: Valor neto total
- **IVA**: Total de impuestos IVA
- **INC**: Total impuesto al consumo (bolsas)
- **TOTAL**: Total general del pedido

#### Información Adicional
- **Cantidad total**: Sumatoria de todas las cantidades
- **Total líneas**: Número de líneas en el pedido

## Flujo de Trabajo

### 1. Preparación del Pedido
1. **Seleccionar cliente**: Busque y seleccione el cliente en la pestaña "THIRD"
2. **Verificar datos**: Confirme que los datos del cliente sean correctos
3. **Seleccionar vendedor**: Asigne el vendedor responsable
4. **Configurar vigencia**: Ajuste los días de vigencia si es necesario
5. **Ingresar orden externa**: Si el cliente proporcionó número de orden

### 2. Adición de Productos
1. **Acceder a tabla**: Vaya a la pestaña "Pedido"
2. **Buscar producto**: Use F2 o digite directamente el código
3. **Ingresar cantidad**: Especifique la cantidad requerida (solo enteros)
4. **Seleccionar lista**: Elija la lista de precios apropiada (1, 2 o 3)
5. **Verificar descuentos**: Los descuentos se aplican automáticamente
6. **Revisar totales**: Verifique que los cálculos sean correctos

### 3. Gestión de Temporales (Opcional)
1. **Guardar temporal**: Si el pedido es largo, use la función de guardado temporal
2. **Recuperar temporal**: En sesiones posteriores, recupere el pedido desde la pestaña "Temporales"
3. **Continuar edición**: Complete el pedido con productos adicionales

### 4. Finalización
1. **Revisar información**: Verifique todos los datos antes de guardar
2. **Guardar pedido**: El botón "Guardar" genera el pedido en base de datos
3. **Impresión automática**: Se genera automáticamente impresión en tamaño carta
4. **Limpieza automática**: El formulario se limpia para el siguiente pedido

## Botones y Controles

### Botones Principales
- **Guardar**: Genera el pedido, guarda en base de datos e imprime
- **Limpiar**: Limpia todos los campos para nuevo pedido
- **Cerrar**: Cierra el formulario

### Controles Especiales
- **F2**: Búsqueda avanzada de productos
- **Combo Vendedor**: Selección de vendedor desde lista configurada
- **Combo Temporales**: Gestión de pedidos guardados temporalmente

## Validaciones y Restricciones

### Campos Obligatorios
- ✅ **Cliente**: Debe seleccionar un tercero válido
- ✅ **Correo electrónico**: Obligatorio para facturación electrónica
- ✅ **Al menos un producto**: Debe tener productos en la tabla

### Restricciones de Cantidad
- ❌ **No se permiten decimales** en las cantidades
- ✅ **Solo números enteros** positivos
- ✅ **Mínimo 0** (cero anula la línea)

### Listas de Precios
- **Lista 1**: Disponible para todos los clientes
- **Lista 2**: Solo clientes con configuración especial
- **Lista 3**: Solo clientes con configuración especial

## Características Técnicas

### Integración con Otros Sistemas
- **Facturación electrónica**: El correo es obligatorio para el siguiente proceso
- **Inventarios**: Consulta disponibilidad en tiempo real
- **Terceros**: Integración completa con maestro de clientes
- **Promociones**: Aplicación automática de descuentos vigentes
- **Sistema de puntos**: Integración con plan de puntos por referidos

### Configuraciones Automáticas
- **Correo por defecto**: Si el cliente no tiene correo configurado
- **Vigencia**: 1 día por defecto, modificable
- **Lista de precios**: Automática según el cliente
- **Bodega**: Configuración automática según sucursal
- **Numeración**: Consecutivo automático por tipo de documento

## Notas Importantes

### ⚠️ Para Desarrollo
- La celda de descuento debe estar desactivada para funcionamiento correcto
- Los cálculos de descuento se manejan automáticamente por el sistema

### 💡 Consejos de Uso
- Use el guardado temporal para pedidos largos
- Verifique la disponibilidad antes de confirmar cantidades grandes
- El sistema de listas de precios se ajusta automáticamente al cliente
- Los descuentos por promociones se aplican automáticamente

### 🔄 Estado de Desarrollo
Este formulario está **EN DESARROLLO** para pedidos JBE y puede recibir actualizaciones que mejoren su funcionalidad.

---

*Documento generado automáticamente basado en la configuración del formulario JBTR00001_perfil.xml*
*Fecha: 24 Octubre 2025*