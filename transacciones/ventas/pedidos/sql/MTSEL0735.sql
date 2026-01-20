drop table if exists aux_listado_empleados;
create temp table aux_listado_empleados as
SELECT 
	i.id,
	i.sigla 
FROM 
	info_empleado i,
	empleados_sucursal e,
	administracion_sucursales a
WHERE
	a.id_bodega_ppal = '?' AND
	a.id_administracion_sucursales = e.id_administracion_sucursales AND
	i.estado='ACT' AND
	i.id = e.id
	--i.id_cargo_empleado = 'VEN'
union
SELECT 
	i.id,
	i.sigla 
FROM 
	info_empleado i
WHERE
	i.estado='ACT' AND
	i.id = 209; -- don jose aparece en todas las sucursales
	
select
	id,
	sigla
from
	aux_listado_empleados
ORDER BY
	sigla::integer;

