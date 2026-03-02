--CRP241
with aux_parametros_query as (
select
	'?'::date as fechai,
	'?'::date as fechaf,
	trim('?'::text) as id_char
		),
aux_listado_movimientos as (
select
	ie.sigla,
 	trim(coalesce(g.nombre1,'')||' '||coalesce(g.nombre2,'')||' '||coalesce(g.apellido1,'')||' '||coalesce(g.apellido2,'')||' '||coalesce(g.razon_social,'')) as nombre_tercero,
 	case when d.codigo_tipo like 'Z%' then dd.valor else 0 end as ventas_contado,
 	case when d.codigo_tipo like 'G%' then dd.valor else 0 end as ventas_credito,
 	dd.valor as ventas_totales
from
	aux_parametros_query a,
	documentos d
inner join
	info_documento id
on
	d.ndocumento = id.ndocumento
inner join
	datos_documento dd
on 	
	d.ndocumento = dd.ndocumento 
left join
	info_empleado ie
on 	
	id.id_vendedor = ie.id 
left join
	general g
on
	id.id_vendedor = g.id
where
	(d.codigo_tipo like 'Z%' or 
	d.codigo_tipo like 'G%') and
	d.estado and
	d.fecha::date between a.fechai and a.fechaf and
	case when a.id_char is null or a.id_char = '' then true else g.id_char = a.id_char end
)
select
	a.sigla,
 	a.nombre_tercero,
 	sum(a.ventas_contado) as ventas_contado,
 	sum(a.ventas_credito) as ventas_credito,
 	sum(a.ventas_totales) as ventas_totales
from
	aux_listado_movimientos a
group by
	a.sigla,
 	a.nombre_tercero
order by
	a.sigla::integer;
