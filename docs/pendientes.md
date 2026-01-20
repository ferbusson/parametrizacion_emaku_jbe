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
- [x] Recordar acerca de resoluciones de facturacion
- [x] Poner facturacion Credito
- [x] Poner facturacion Contingencia
- [x] Poner traslados bodegas a perfiles vendedores
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
- [x] hacer que el tercero rápido solo muestre cedula
- [ ] hacer que el tercero rápido guarde el teléfono de jbe por defecto
- [x] hacer que se pueda recibir abonos a sistecredito por medio de abono a cartera
- [x] revisar que el perfil de factura credito este ok en las sucursales
- [ ] revisar el reporte de informe diario
- [x] revisar cuentas para transferencias
- [ ] ver el tema de devoluciones con Jairo, para que las haga el cajero
- [ ] confirmar solicitud de validacion para no se pueda vender productos por debajo del costo

- [ ] agregar impresion carta a abonos a cartera
- [x] validar que la factura a credito valide los cupos y dias de crédito
- [ ] subir precios de lista constructora
- [x] f2 limitarlo y mostrar saldo y precios

- [x] revisar retenciones de los regimenes
- [x] revisar tarjetas y consignaciones en recaudo de revision de arqueos
- [x] revisar por qué no carga las bodegas en nuevo traslado multisucursal
- [x] cerrar los dias de credito que dependa del tercero y que no se pueda poner en el formulario
	consultar cupo
	poner la consulta de dias de credito en el componente
	validar que no se pueda guardar si los dias de credito son cero
	consultar el cupo y validar que la factura sea menor o igual a ese cupo
	
x revisar impresion nueva factura credito los dias de credito deben ser los dias de credito

Revisar reporte diario por almacen
Revisar los ajustes de inventarios
Revisar porque existe saldo negativo en la referencia 3040105


- [x] dejar el combo de vendedores en blanco y validar que sea obligatorio (facturas)
- [x] actualizar precios de venta de varios (3 listas ) en 2% mas en Varios grupos 151 a 199 exceptuando servicios y cortes
- [ ] los anticipos solo se pueden usar en la sucursal donde se registra el anticipo, comentar esto con:
	- [ ] Jairo
	- [ ] Dario

- [ ] Revisar los puntos generados de los clientes con javipuntos




### Comentarios

La factura credito genera confusion porque esta en otro formulario
La creación de terceros rapido solo permite crear terceros naturales
Hace falta dejar claro como crear un Nit o una persona con cédula

Arqueos:

1COMPARAR LAS DOS TOTALES MEDIOS DE PAGO RECAUDO
2 VENTAS CON TARJETA DETALLADO (medios de pago)

3 TOTAL VENTAS DE CONTADO 
TOTAL VENTAS DE CREDITO deben coincidir con el reporte 1

ok En el MTR00202 poner el usuario

Dario borrar contabilizacion de cajas del punto a tesoreria

Transferencia de dinero de caja mayor a banco


## Pagos - Egresos
Producto con averia: hacen un descuento a la factura
Rebate: regalos: impadoc Los regalos son bonificaciones los regalos no cobran iva
Rebate: otros no afecta iva, no es rebaja en el precio (plata) se va a otros ingresos rebate trimestral, por producto, 
Pintuco nota de compensacion cuando devuelve el 10 % de los mier de color (15) se manejaria como otro ingreso
Garantia pueden reenviar el producto o ellos crean una nota credito (devo dinero)
Apoyo mercadeo y publicidad

Bodega Prods Danados (garantias)


Los anteriores descuentos requieren cuenta, valor, numero de nota

Reporte Pintuco:

Programacion de pagos: se hacen por pse no problema, los que son por banco deberian notificarse



dejar un solo descuento
calcular el descuento de la base de la factura
poner check box para seleccionar factura total
Permitir seleccionar la fecha
Combo con medios de pago: listado de cuentas de bancos y efectivo


### Tareas:
- [ ] Agregar calendario para seleccionar fecha
- [x] Poner check box en la primera columna
- [x] Quitar descuentos 2 y 3
- [x] Calcular descuentos a partir de la base
