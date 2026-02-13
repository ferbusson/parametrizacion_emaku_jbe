--JBSEL0076 Reporte JBSAS
select
	coalesce(rf.prefijo,d.codigo_tipo)||'-'||d.numero::bigint as numero_doc,
	d.fecha::date as fecha,
	d.fecha::time::text as hora,
	--ps.codigo,
	i.ref_proveedor as codigo,
	--i.ref_proveedor as referencia,
	ps.codigo_b as referencia,
	ps.codigo as cod_barras,
	i.nombre as descripcion,
	'Unidad' as unidad_medida,
	dp.cant as cantidad,
			case when asu.id_administracion_sucursales = 1 then 'PPAL' 
			when asu.id_administracion_sucursales = 2 then 'L21'
			when asu.id_administracion_sucursales = 3 then 'CARPI'
			when asu.id_administracion_sucursales = 4 then 'AV1515'
			when asu.id_administracion_sucursales = 5 then 'PPAL'
			when asu.id_administracion_sucursales = 6 then 'PPAL'
			when asu.id_administracion_sucursales = 7 then 'PPAL'
			else '--'
			end as almacen,
	case when asu.id_administracion_sucursales = 1 then 'TIENDA PINTUCO' 
			when asu.id_administracion_sucursales = 2 then 'PUNTO CARRERA21A'
			when asu.id_administracion_sucursales = 3 then 'TIENDA PUCALPA'
			when asu.id_administracion_sucursales = 4 then 'TIENDA AV1515'
			when asu.id_administracion_sucursales = 5 then 'TIENDA PINTUCO'
			when asu.id_administracion_sucursales = 6 then 'TIENDA PINTUCO'
			when asu.id_administracion_sucursales = 7 then 'TIENDA PINTUCO'
			else '--'
			end as equivalencia,
	case when dst.nombre in ('DVENTA ELECTRONICA') then 1 else 0 end as tipo_venta,
	case when dst.nombre in ('DVENTA ELECTRONICA') then 'DEVOLUCION' else 'VENTA' end as equivalencia,
	trim(coalesce(g2.apellido1,'')||' '||coalesce(g2.apellido2,'')||' '||coalesce(g2.nombre1,'')||' '||coalesce(g2.nombre2,'')||' '||coalesce(g2.razon_social,'')) as nombre_vendedor,
	g2.id_char as cedula_vendedor,
	g.id_char as codigo_cliente,
	trim(coalesce(g.apellido1,'')||' '||coalesce(g.apellido2,'')||' '||coalesce(g.nombre1,'')||' '||coalesce(g.nombre2,'')||' '||coalesce(g.razon_social,'')) as nombre,
	g.id_char as nit,
	dir.direccion,
	mun.id_dep||mun.municipio as cod_municipio,
	mun.nombre as municipio,
	cpv.id_catalogo as cod_tipo_negocio,
	cpv.nombre as nombre_tipo_negocio,		
	ROUND((ROUND(((dp.pventa))::NUMERIC,0)/(1+(dp.iva/100)))::NUMERIC,0) as P_Lista_Antes_Dto, --confirmar si es el valor por la cantidad
	dp.descuento1 as descuento,
	--(dp.pventa/(1+(dp.iva/100))):: - round((dp.pventa/(1+(dp.iva/100))*(dp.descuento1/100))::numeric,0) as P-Final_antes_iva
	ROUND((ROUND(((dp.pventa)-((dp.pventa)*(dp.descuento1/100)))::NUMERIC,0)/(1+(dp.iva/100)))::NUMERIC,0)*dp.cant AS pventa_final_antes_iva, --preguntar si va redondeado a cero
	--ROUND(((dp.pventa)-((dp.pventa)*(dp.descuento1/100)))::NUMERIC,0) AS valor_total, este incluye el descuento agregar la cant si se confirma
	case when dp.descuento1 = 15 and EXTRACT(DOW FROM fecha::date) = 3 then 'Miercoles del Color' else '' end as nombre_actividad -- solo si es 15 en desc y la fecha es miercoles
from
	documentos_standar dst
inner join
	documentos_sucursales ds
on
	dst.id_documento = ds.id_documento
inner join
	administracion_sucursales asu
on
	ds.id_administracion_sucursales = asu.id_administracion_sucursales
inner join
	documentos d
on
	ds.codigo_tipo = d.codigo_tipo
inner join
	resolucion_documento rd
on
	d.ndocumento = rd.ndocumento
inner join
	resolucion_facturacion rf
on
	rd.id_resolucion_facturacion = rf.id_resolucion_facturacion
inner join
	datos_prod dp
on
	d.ndocumento = dp.ndocumento
inner join
	prod_serv ps
on
	dp.id_prod_serv = ps.id_prod_serv
inner join
	item i
on	
	ps.id_item = i.id_item
inner join
	tercero_def td
on
	d.ndocumento = td.ndocumento
inner join
	general g
on
	td.id = g.id
inner join
	direcciones dir
on
	td.id_direccion = dir.id_direccion
inner join
	municipios mun
on
	dir.id_dep = mun.id_dep
	and dir.municipio = mun.municipio
inner join
	catalogo_pventa cpv
on
	td.id_catalogo = cpv.id_catalogo
inner join
	info_documento id
on
	d.ndocumento = id.ndocumento
inner join
	info_empleado ie
on
	id.id_vendedor = ie.id
inner join
	general g2
on
	ie.id = g2.id
where
	ps.id_talla between 1 and 150
	and dst.nombre in ('FCREDITO','DVENTA ELECTRONICA','FELECTRONICAPOS','FCONTINGENCIAE','FCONTINGENCIA')
	and d.fecha::date between '?' and '?'
order by
	coalesce(rf.prefijo,d.codigo_tipo),
	d.numero::bigint;

