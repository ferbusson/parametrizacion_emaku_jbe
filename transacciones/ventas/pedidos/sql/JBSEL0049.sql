--JBSEL0049
select
    d.ndocumento
from
	documentos_standar ds
inner join
    documentos_sucursales dsl
on
	dsl.id_documento = ds.id_documento
inner join
    documentos d    
ON
	d.codigo_tipo = dsl.codigo_tipo
WHERE
    ds.nombre = 'COTIZACION' -- solo consultamos cotizaciones, se usa en pedidos, lo valido asi para no asociar pedidos anteriores que es otra de las opciones
    AND d.codigo_tipo = '?'
    AND d.numero = lpad('?',10,'0')
	and not exists (select 1 from info_documento i where i.rf_documento = d.ndocumento) ; -- validamos que la cotizacion no haya sido usada en otro pedido