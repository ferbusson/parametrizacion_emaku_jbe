--JBSEL0109
with aux_parametros_reporte as(
select
	'?'::date as fecha_inicio,
	'?'::date as fecha_fin)
select 	
	td.descripcion as tipo_factura,
	d.fecha::date as fecha,
	coalesce(rf.prefijo,d.codigo_tipo)||'-'||d.numero::bigint as factura,
	dd.efectivo,
	dd.tcredito,
	dd.tdebito,
	dd.cheque,
	dd.consignacion,
	dd.cxc,
	dd.cxp,
	dd.anticipo 
from
	documentos d
inner join
	tipo_documento td 
on
	d.codigo_tipo = td.codigo_tipo 
inner join
	datos_documento dd 
on
	d.ndocumento = dd.ndocumento 
left join 
	resolucion_documento rd 
on
	d.ndocumento = rd.ndocumento 
left join
	resolucion_facturacion rf 
on
	rd.id_resolucion_facturacion = rf.id_resolucion_facturacion 
where
	(d.codigo_tipo like 'Z%' or
	d.codigo_tipo like 'G%') AND
	d.fecha between (select fecha_inicio::timestamp from aux_parametros_reporte) and
	(select fecha_fin::timestamp from aux_parametros_reporte)
order by 
	coalesce(rf.prefijo,d.codigo_tipo)||'-'||d.numero::bigint;