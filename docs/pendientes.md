# Listado Pendientes

## Parametrizacion

- [x] Factura Electronica debe guardar su propia informacion de contacto (direccion y telefono de contacto)
- [x] Hacer script de subida de saldos iniciales
- [x] Agregar Nequi, Daviplata etc en forma de pago (Como tarjetas)
- [x] Poner prefijo de Pedidos por cada sucursal
- [x] Nuevo Pedido Marcar con color cuando la cantidad de la cotizacion es menor a la cantidad disponible
- [x] Revisar pago con todas las tarjetas Nueva Factura
- [x] Crear usuarios sistema con sus permisos y sucursal
- [x] Verificar que en Javipuntos solo se puedan digitar personas habilitadas para javipuntos
- [x] Cambiar letrero que dice: *Carta: 1 (Default)* por *Mostrador: 1 (Default)*
- [x] Al llamar la cotización desde el Pedido conservar los precios de la cotización
- [x] Al llamar a la cotizacion desde el Pedido debe llamar al tercero (solo para este caso) si son pedidos anteriores con la lista esta ok Preguntar
- [x] En pedidos: validar que no se pueda llamar a una cotización ya usada
- [x] En pedidos: validar que no se pueda llamar a una cotización vencida
- [x] En pedidos: hacer cambios a la select de la query que carga temporales para que no suba es_pintor sino 0 para que el vunitario quede libre para editar
- [x] En la impresión de Cotizaciones y Pedidos agregar mas info del tercero, revisar la plantilla de impresión
- [x] Quitar de las opciones de JBE el reporte Contabilidad reportes administrativos detallado de ventas gerencia
- [x] Revisar reportes de venta (excel)
- [x] Corregir error que sale en Abono a CxC al digitar el abono
- [x] Quitar codigo barras impresion tirilla Abono a CxC
- [x] Agregar soporte para OrderReference en la generación de factura electrónica
```xml
<cac:OrderReference>
		<cbc:ID>546326432432</cbc:ID>
		<cbc:IssueDate>2019-01-01</cbc:IssueDate>
</cac:OrderReference>
```
- [x] Revisar el boton limpiar de la factura electronica tiene errores despues de quitar los componentes de retenciones en la forma de pago
- [x] Migrar productos nuevamente


### Relacion entre documentos

`Cotizacion <- Pedido <- Factura:`
* el ndocumento de la cotizacion esta en el rf_documento de info_documento del pedido
* el ndocumento del pedido esta en el rf_documento de info_documento de la factura

### Consideraciones al anular
- Anular cotizacion debe verificar que su ndocumento **No** sea el rf_documento de un pedido con estado = true


- Anular pedido debe verificar que su ndocumento **No** sea el rf_documento de una factura con estado = true
- Anular pedido debe actualizar su info_documento con rf_documento = null para liberar la cotizacion asociada si la hay


- [ ] Preguntar perfiles de Oscar y Daniela
- [ ] Recordar acerca de resoluciones de facturacion
- [x] Poner facturacion Credito
- [ ] Poner facturacion Contingencia
- [ ] Poner traslados bodegas a perfiles vendedores
- [x] Poner como administrador el perfil de Jairo Moncayo 

- [x] Reporte de Cotizaciones por Tercero
- [x] Reporte de Facturas por Tercero
- [x] Listado de siglas de vendedores por sucursal
- [x] Hacer que se habilite la edicion de vunitario para los productos de combinaciones
- [ ] Ver la posibilidad de mejorar el contraste de la letra en el F2
- [x] Habilitar la consulta bodegas para vendedores
- [x] Habilitar el maestro de productos
- [x] Habilitar el re envio de facturas por correo electrónico
- [x] Habilitar facturas de contingencia a usuarios
- [x] Poner plantilla impresion en server propia para facs credito donde se imprima el nombre de la plataforma: Ej: sistecredito
 
# Preguntas para Dia Inicio:

-  Cómo y quien inscribe la gente a Javipuntos (Perfil Editar Terceros)
-

No borrar:

FC
1C
SI

Z1 PRINCIPAL
Z2 CARRERA 21
Z3 CASA DEL CARPINTERO
Z4 AMERICAS 15-15
Z5 ICO
Z6 SIKA
Z7 CARPINTERO CENTRO


11100503 BCO DAVIVIENDA CTA CTE -> BANCOLOMBIA 4902
11100505 BCO BANCOLOMBIA CTA CTE -> BANCO DAVIVIENDA 4585
11100506 BANCO DAVIVIENDA 9255 OK





mdjw nxaw pblv ikba 


- [ ] habilitar reportes de cartera por edades
- [ ] habilitar reportes de cxp
- [ ] hacer que se imprima el nombre del usuario no solo el login
- [ ] revisar el reporte de libros auxiliares no saca info
- [x] exportar el listado de productos para que lo puedan modificar y reimportar
- [ ] hacer que el tercero rápido guarde la direccion de jbe por defecto
- [ ] hacer que el tercero rápido solo muestre cedula
- [ ] hacer que el tercero rápido guarde el teléfono de jbe por defecto
- [ ] hacer que se pueda recibir abonos a sistecredito por medio de abono a cartera
- [x] revisar que el perfil de factura credito este ok en las sucursales
- [ ] revisar el reporte de informe diario
- [ ] revisar cuentas para transferencias
- [ ] ver el tema de devoluciones con Jairo, para que las haga el cajero
- [ ] confirmar solicitud de validacion para no se pueda vender productos por debajo del costo


