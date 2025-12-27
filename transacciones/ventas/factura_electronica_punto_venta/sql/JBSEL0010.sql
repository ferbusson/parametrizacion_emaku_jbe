/* Retorna el prefijo del documentos mostrador que le corresponde al prefijo que le llega como argumento
 * usado para poder llamar al pedido desde la factura electronica pos
 * */

select
	ds2.codigo_tipo 
from
	documentos_sucursales ds
inner join
	documentos_sucursales ds2
on
	ds.id_administracion_sucursales = ds2.id_administracion_sucursales 
where
	ds.id_documento in (28,17,33,23) -- factura electronica pos | factura crédito | contingencia factura contado pos | contingencia factura credito  
	and ds2.id_documento = 34 -- documento mostrador
	and ds.codigo_tipo = '?' -- prefijo de la forma
LIMIT 1;