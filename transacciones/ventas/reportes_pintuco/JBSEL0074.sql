-- JBSEL0074 Reporte Pintuco seccion Ventas
select
	d.fecha::date as fecha,
	coalesce(rf.prefijo,d.codigo_tipo)||'-'||d.numero::bigint as Numero_Doc,
	i.ref_proveedor as Codigo_Producto,
	i.nombre as Nombre_Producto,
	'Unidad' as Uni_Medida,
	ps.codigo_b as Referencia,
	ps.codigo as Cod_Barras,
	dp.cant as Cantidad,
	ROUND(((dp.pventa)-((dp.pventa)*(dp.descuento1/100)))::NUMERIC,0)*dp.cant AS Valor_Total,
	case when dst.nombre in ('DVENTA ELECTRONICA') then 1 else 0 end as Tipo_Venta,
	g.id_char as codigo_clte,
	trim(coalesce(g.apellido1,'')||' '||coalesce(g.apellido2,'')||' '||coalesce(g.nombre1,'')||' '||coalesce(g.nombre2,'')||' '||coalesce(g.razon_social,'')) as Nombre,
	g.id_char as Nit,
	dir.direccion as Direccion,
	mun.id_dep||mun.municipio as Cod_Municipio,
	mun.nombre as Nombre_Municipio,
	cpv.id_catalogo as Cod_Tipo_Negocio,
	cpv.nombre as Nombre_Tipo_Negocio,
	ie.sigla as Cod_Vendedor,
	trim(coalesce(g2.apellido1,'')||' '||coalesce(g2.apellido2,'')||' '||coalesce(g2.nombre1,'')||' '||coalesce(g2.nombre2,'')||' '||coalesce(g2.razon_social,'')) as Nombre_del_Vendedor,
	g2.id_char as Cedula_Vendedor
from
	documentos_standar dst
inner join
	documentos_sucursales ds
on
	dst.id_documento = ds.id_documento
inner join
	documentos d
on
	ds.codigo_tipo = d.codigo_tipo
left join
	resolucion_documento rd
on
	d.ndocumento = rd.ndocumento
left join
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
left join
	info_empleado ie
on
	case when id.id_vendedor is not null then id.id_vendedor = ie.id else id.id_usuario = ie.id end
left join
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
