-- JBSEL0075 Reporte Pintuco - Sección Inventarios
drop table if exists aux_parametros_reporte;
create temp table aux_parametros_reporte as
select
	'?'::date as fecha_inicial,
	'?'::date as fecha_final;


drop table if exists aux_prods_reporte_inventario;
create temp table aux_prods_reporte_inventario as
SELECT distinct
	--d.fecha::date as fecha,
	ps.id_prod_serv,
	ps.codigo,
	trim(i.ref_proveedor) as referencia,
	--dp.cant as cantidad,
	'UN' as unidad_medida,
	trim(i.nombre) as nombre
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
	id.id_vendedor = ie.id
left join
	general g2
on
	ie.id = g2.id
where
	ps.id_talla between 1 and 150
	and dst.nombre in ('FCREDITO','DVENTA ELECTRONICA','FELECTRONICAPOS','FCONTINGENCIAE','FCONTINGENCIA')
	and d.fecha::date between (select fecha_inicial from aux_parametros_reporte) and (select fecha_final from aux_parametros_reporte);

--

drop table if exists aux_saldos_reporte_inventario;
create temp table aux_saldos_reporte_inventario as
select
	i.id_prod_serv,
	sum(coalesce(i.entrada,0))-sum(coalesce(i.salida,0)) as saldo
from
	inventarios i
inner join
	aux_prods_reporte_inventario a
on
	i.id_prod_serv = a.id_prod_serv
inner join
	documentos d
on
	i.ndocumento = d.ndocumento
where
	d.estado
	and i.fecha::Date <= (select fecha_final from aux_parametros_reporte)
group by
	i.id_prod_serv;
	
	
select
	(select fecha_final from aux_parametros_reporte) as fecha,
	ps.codigo,
	ps.referencia,
	i.saldo as cantidad,
	ps.unidad_medida,
	ps.nombre
from
	aux_prods_reporte_inventario ps
inner join
	aux_saldos_reporte_inventario i
on
	ps.id_prod_serv = i.id_prod_serv
order by
	nombre;