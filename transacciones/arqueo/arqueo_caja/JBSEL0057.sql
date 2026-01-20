--JBSEL0057
drop table if exists aux_parametros_sucursales;
create temp table aux_parametros_sucursales as
select
	'?'::date as fecha_ini,
	'?'::date as fecha_fin,
	'?'::varchar as id_sucursal,
	'?'::varchar as id_char_usuario;

select
	t.nombre as sucursal,
	trim(coalesce(g.nombre1,'')||' '||coalesce(g.nombre2,'')||' '||coalesce(g.apellido1,'')||' '||coalesce(g.apellido2,'')||' '||coalesce(g.razon_social,'')) as nombre,
	u.login as usuario,
	td.descripcion as tipo_documento,
	coalesce(rf.prefijo,d.codigo_tipo)||'-'||d.numero::bigint as documento,
	d.fecha,
	CASE WHEN d.estado THEN 'HABILITADO' ELSE 'ANULADO' END AS estado,
	coalesce(dd.valor,0) as valor,
	coalesce(dd.efectivo,0) as efectivo,
	coalesce(dd.tcredito,0) as tcredito,
	coalesce(dd.tdebito,0) as tdebito,
	coalesce(dd.consignacion,0) as consignacion,
	coalesce(dd.cheque,0) as cheque,
	coalesce(dd.cxc,0) as cxc
from
	aux_parametros_sucursales a,
	documentos d
inner join
	info_documento id
on
	d.ndocumento = id.ndocumento 	
inner join
	tipo_documento td
on
	d.codigo_tipo = td.codigo_tipo 
inner join
	usuarios u
on
	id.id_usuario = u.id_usuario 
inner join
	general g
on	
	id.id_usuario = g.id
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
inner join
	documentos_sucursales ds 
on
	d.codigo_tipo = ds.codigo_tipo 
inner join
	administracion_sucursales t 
on
	ds.id_administracion_sucursales  = t.id_administracion_sucursales
inner join
	documentos_standar dst
on
	ds.id_documento = dst.id_documento 
where
	dst.nombre in ('ANTICIPOS FACTURACION','COMPROBANTES INGRESO','DVENTA ELECTRONICA','ENTREGA BASE SENCILLA','FCONTINGENCIA','FCONTINGENCIAE','FCREDITO','FELECTRONICAPOS')
	and d.fecha::date between a.fecha_ini and a.fecha_fin
	and case when a.id_sucursal is not null and trim(a.id_sucursal) != '' then a.id_sucursal::integer = t.id_administracion_sucursales else true end
	and case when a.id_char_usuario is not null and trim(a.id_char_usuario) != '' then a.id_char_usuario = u.login else true end
order by
	t.nombre,
	u.login,
	d.codigo_tipo,
	d.numero::bigint;