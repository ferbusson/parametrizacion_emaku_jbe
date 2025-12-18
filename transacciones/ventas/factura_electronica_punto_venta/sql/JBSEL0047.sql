--JBSEL0047
with aux_parametros_query as (
select
	d.ndocumento,
    d.fecha
from
	documentos d
where
	d.codigo_tipo = '?' 
	and d.numero = lpad('?',10,'0')
)

select
	ca.total_factura,
	ca.dcredito,
	cu.nombre,
    (select fecha::date + coalesce(ca.dcredito,0) from aux_parametros_query) as vencimiento_factura
from
	cartera ca
inner join
	cuentas cu
on
	ca.id_cta = cu.id_cta 
where 	
	ca.nfactura = (select ndocumento from aux_parametros_query)
	and cu.char_cta  like '1305%'
	and ca.movimiento 
limit 1;