
--JBSEL0089

with aux_parametros_query as (
select
	d.ndocumento
from
	documentos d
where
    d.codigo_tipo='?' AND    
    d.numero=LPAD('?',10,'0')
) 
, aux_prefijos_devoluciones as (
select
	ds2.codigo_tipo
from
	documentos_standar ds 
inner join
	documentos_sucursales ds2 
on
	ds.id_documento = ds2.id_documento 
where
	ds.nombre = 'DVENTA ELECTRONICA'
)
,aux_devs_asociadas_a_factura as (
select
	a.ndocumento as ndocumento_factura,
	d.*,
	dp.id_bodega,
	dp.id_prod_serv,
	dp.cant
from
	aux_parametros_query a
inner join
	info_documento id
on
	a.ndocumento = id.rf_documento
inner join
	documentos d
on
	id.ndocumento = d.ndocumento 
inner join
	aux_prefijos_devoluciones apr
on
	apr.codigo_tipo = d.codigo_tipo 
inner join 
	datos_prod dp
on
	d.ndocumento = dp.ndocumento 
where
	d.estado
)
, aux_cruce_con_devoluiciones as (
select DISTINCT
	adev.codigo_tipo,
	adev.numero,
	adev.fecha::date as fecha_dev
from
	aux_parametros_query a
inner join
	datos_prod dp
on
	a.ndocumento = dp.ndocumento
left join
	aux_devs_asociadas_a_factura adev
on
	a.ndocumento = adev.ndocumento_factura
	and dp.id_prod_serv = adev.id_prod_serv 
where
	dp.cant - coalesce(adev.cant,0) = 0
)

SELECT 
    'Devoluciones anteriores: '||string_agg((a.codigo_tipo||'-'||a.numero::bigint||' Fecha: '||a.fecha_dev), ', ' order by a.codigo_tipo, a.numero)
	--*
FROM 
	aux_cruce_con_devoluiciones a;