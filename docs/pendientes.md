# Listado Pendientes

## Parametrizacion

- [x] Factura Electronica debe guardar su propia informacion de contacto (direccion y telefono de contacto)
- [ ] Hacer script de subida de saldos iniciales
- [ ] Agregar Nequi, Daviplata etc en forma de pago (Como tarjetas)
- [x] Poner prefijo de Pedidos por cada sucursal
- [x] Nuevo Pedido Marcar con color cuando la cantidad de la cotizacion es menor a la cantidad disponible
- [ ] Revisar pago con todas las tarjetas Nueva Factura
- [ ] Crear usuarios sistema con sus permisos y sucursal
- [ ] Verificar que en Javipuntos solo se puedan digitar personas habilitadas para javipuntos
- [x] Cambiar letrero que dice: *Carta: 1 (Default)* por *Mostrador: 1 (Default)*
- [x] Al llamar la cotización desde el Pedido conservar los precios de la cotización
- [x] Al llamar a la cotizacion desde el Pedido debe llamar al tercero (solo para este caso) si son pedidos anteriores con la lista esta ok Preguntar
- [x] En pedidos: validar que no se pueda llamar a una cotización ya usada
- [x] En pedidos: validar que no se pueda llamar a una cotización vencida
- [x] En pedidos: hacer cambios a la select de la query que carga temporales para que no suba es_pintor sino 0 para que el vunitario quede libre para editar
- [ ] En la impresión de Cotizaciones y Pedidos agregar mas info del tercero, revisar la plantilla de impresión
- [ ] Quitar de las opciones de JBE el reporte Contabilidad reportes administrativos detallado de ventas gerencia
- [ ] Revisar reportes de venta (excel)
- [x] Corregir error que sale en Abono a CxC al digitar el abono
- [ ] Quitar codigo barras impresion tirilla Abono a CxC
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