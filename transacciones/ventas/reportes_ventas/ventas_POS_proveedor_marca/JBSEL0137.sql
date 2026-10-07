--JBSEL0137
drop table if exists aux_parametros_reporte;
create temp table aux_parametros_reporte as
with aux_detalle_parametros as(
	select
		'?'::date as fecha_inicial,
		'?'::date as fecha_final,
		trim('?'::varchar) as id_bodega
)
select
	ad.fecha_inicial,
	ad.fecha_final,
	ds.codigo_tipo
from
	administracion_sucursales a
join
	documentos_sucursales ds
on
	a.id_administracion_sucursales = ds.id_administracion_sucursales 
join
	documentos_standar dst
on
	ds.id_documento = dst.id_documento
join
	aux_detalle_parametros ad
on
	true
where
	dst.nombre = 'FCREDITO' and	
	case when ad.id_bodega = '-1' then true else ad.id_bodega = a.id_bodega_ppal::varchar end;

drop table if exists aux_dias_vencimiento_cartera;
create temp table aux_dias_vencimiento_cartera as
select
	d.ndocumento,
	ca.dcredito 
from
	documentos d
inner join
	cartera ca
on
	d.ndocumento = ca.nfactura
where
	d.codigo_tipo like 'G%' and
	ca.ncomprobante is null and
	ca.dcredito is not null and
	ca.total_factura is not null and
	ca.total_factura != 0;



select
	u.login as usuario,
	trim(coalesce(g.nombre1,'')||' '||coalesce(g.nombre2,'')||' '||coalesce(g.apellido1,'')||' '||coalesce(g.apellido2,'')||' '||coalesce(g.razon_social,'')) as nombre_usuario,
	ie.sigla,
	case when substring(d.codigo_tipo,2,2) = '1' then 'PPAL' 
		when substring(d.codigo_tipo,2,2) = '2' then 'L21'
		when substring(d.codigo_tipo,2,2) = '3' then 'CARPI'
		when substring(d.codigo_tipo,2,2) = '4' then 'AV1515'
		when substring(d.codigo_tipo,2,2) = '5' then 'ICO'
		when substring(d.codigo_tipo,2,2) = '6' then 'SIKA'
		when substring(d.codigo_tipo,2,2) = '7' then 'CARP CENTRO'
		else '--'
	end as sucursal,
	trim(coalesce(gv.nombre1,'')||' '||coalesce(gv.nombre2,'')||' '||coalesce(gv.apellido1,'')||' '||coalesce(gv.apellido2,'')||' '||coalesce(gv.razon_social,'')) as nombre_vendedor,	
	coalesce(rf.prefijo,d.codigo_tipo)||'-'||d.numero::bigint as numero_factura,	
	d.fecha,
	ca.dcredito,
	trim(coalesce(gtf.nombre1,'')||' '||coalesce(gtf.nombre2,'')||' '||coalesce(gtf.apellido1,'')||' '||coalesce(gtf.apellido2,'')||' '||coalesce(gtf.razon_social,'')) as nombre_cliente,
	(d.fecha::date + interval '1 day' * ca.dcredito)::date as vencimiento,
	case when d.codigo_tipo like 'G%' then SUM(coalesce(haber::numeric,0)) else 0 end as ventasantesdeiva,
	dd.valor as total_factura
from
	documentos d
join
	info_documento id
on
	d.ndocumento = id.ndocumento 
join
	datos_documento dd
on
	d.ndocumento = dd.ndocumento 
join
	tercero_def td
on
	d.ndocumento = td.ndocumento
inner join
	libro_auxiliar la
on 	
	d.ndocumento = la.ndocumento
inner join
	cuentas cu
on
	la.id_cta = cu.id_cta
join
	general gtf
on
	td.id = gtf.id
join
	usuarios u
on
	id.id_usuario = u.id_usuario 
join
	general g
on
	u.id_usuario = g.id
left join
	general gv
on
	id.id_vendedor = gv.id
join
	info_empleado ie 
on
	id.id_vendedor = ie.id 
join
	resolucion_documento rd 
on
	d.ndocumento = rd.ndocumento 
join
	resolucion_facturacion rf 
on
	rd.id_resolucion_facturacion = rf.id_resolucion_facturacion
join
	aux_dias_vencimiento_cartera ca
on
	d.ndocumento = ca.ndocumento
where
	d.codigo_tipo like 'G%' and
	cu.char_cta like '4135%' and
	d.codigo_tipo in (select codigo_tipo from aux_parametros_reporte) and
	d.fecha >= (select fecha_inicial from aux_parametros_reporte limit 1) and
	d.fecha < (select fecha_final + interval '1 day' from aux_parametros_reporte limit 1) and
	d.estado
group by
	u.login,
	trim(coalesce(g.nombre1,'')||' '||coalesce(g.nombre2,'')||' '||coalesce(g.apellido1,'')||' '||coalesce(g.apellido2,'')||' '||coalesce(g.razon_social,'')),
	ie.sigla,
	d.numero,
	d.fecha,
	d.codigo_tipo,
	trim(coalesce(gv.nombre1,'')||' '||coalesce(gv.nombre2,'')||' '||coalesce(gv.apellido1,'')||' '||coalesce(gv.apellido2,'')||' '||coalesce(gv.razon_social,'')),	
	coalesce(rf.prefijo,d.codigo_tipo)||'-'||d.numero::bigint,	
	ca.dcredito,
	trim(coalesce(gtf.nombre1,'')||' '||coalesce(gtf.nombre2,'')||' '||coalesce(gtf.apellido1,'')||' '||coalesce(gtf.apellido2,'')||' '||coalesce(gtf.razon_social,'')),
	(d.fecha::date + interval '1 day' * ca.dcredito)::date,
	dd.valor
order by
	sucursal,
	sigla,
	d.codigo_tipo,
	d.numero::bigint;