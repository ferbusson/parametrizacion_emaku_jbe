--JBSEL0091
with aux_parametros_query as (
select
	date_trunc('month', current_date) as primer_dia_mes_actual,
	date_trunc('month', current_date) + interval '1 month' as primer_dia_mes_siguiente,
	trim('?'::text) as id_vendedor --viene de seleccionar al vendedor por su sigla
		)
,aux_listado_movimientos_ventas as (
select
	d.ndocumento,
	d.codigo_tipo,
	a.primer_dia_mes_actual,
	a.primer_dia_mes_siguiente,
	ie.sigla,
 	trim(coalesce(g.nombre1,'')||' '||coalesce(g.nombre2,'')||' '||coalesce(g.apellido1,'')||' '||coalesce(g.apellido2,'')||' '||coalesce(g.razon_social,'')) as nombre_tercero,
 	case when d.codigo_tipo like 'Z%' then SUM(coalesce(haber::numeric,0)) else 0 end as ventas_contado,
 	case when d.codigo_tipo like 'G%' then SUM(coalesce(haber::numeric,0)) else 0 end as ventas_credito,
 	SUM(coalesce(haber::numeric,0)) as ventas_totales
from
	aux_parametros_query a,
	documentos d
inner join
	info_documento id
on
	d.ndocumento = id.ndocumento
inner join
	libro_auxiliar la
on 	
	d.ndocumento = la.ndocumento
inner join
	cuentas cu
on
	la.id_cta = cu.id_cta
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
	cu.char_cta like '4135%' and
	d.estado and
	d.fecha >= a.primer_dia_mes_actual and 
	d.fecha < a.primer_dia_mes_siguiente and
	ie.id::text = a.id_vendedor
group by
	d.ndocumento,
	d.codigo_tipo,
	a.primer_dia_mes_actual,
	a.primer_dia_mes_siguiente,
	ie.sigla,
	d.codigo_tipo,
 	trim(coalesce(g.nombre1,'')||' '||coalesce(g.nombre2,'')||' '||coalesce(g.apellido1,'')||' '||coalesce(g.apellido2,'')||' '||coalesce(g.razon_social,''))
)
, aux_listado_movimientos_devoluciones as (
select
	a.ndocumento,
	a.primer_dia_mes_actual,
	a.primer_dia_mes_siguiente,
	a.sigla,
 	a.nombre_tercero,
 	case when a.codigo_tipo like 'Z%' then SUM(coalesce(debe::numeric,0)) else 0 end as devoluciones_contado,
 	case when a.codigo_tipo like 'G%' then SUM(coalesce(debe::numeric,0)) else 0 end as devoluciones_credito,
 	SUM(coalesce(debe::numeric,0)) as devoluciones_totales
from
	aux_listado_movimientos_ventas a
left join
	info_documento idd
on
	a.ndocumento = idd.rf_documento
left join
	documentos d2
on
	d2.ndocumento = idd.ndocumento
inner join
	libro_auxiliar la
on 	
	idd.ndocumento = la.ndocumento
inner join
	cuentas cu
on
	la.id_cta = cu.id_cta
where
	d2.codigo_tipo like 'M%' and
	cu.char_cta like '4175%' and
	d2.estado and
	d2.fecha >= a.primer_dia_mes_actual and 
	d2.fecha < a.primer_dia_mes_siguiente
group by
	a.ndocumento,
	a.primer_dia_mes_actual,
	a.primer_dia_mes_siguiente,
	a.sigla,
	a.codigo_tipo,
 	a.nombre_tercero
)
select
 	round(sum(a.ventas_totales - coalesce(d.devoluciones_totales,0))::numeric,0) as ventas_totales
from
	aux_listado_movimientos_ventas a
left join
	aux_listado_movimientos_devoluciones d
on
	a.ndocumento = d.ndocumento and
	a.sigla = d.sigla
limit
	1;
