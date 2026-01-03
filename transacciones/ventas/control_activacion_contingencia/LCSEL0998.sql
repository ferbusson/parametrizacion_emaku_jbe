select
	nombre_sucursal,
	trim(M.descripcion)||' '||M.id_motivo_contingencia as motivo_contingencia,
	activar,
	id_bodega
from
	control_activacion_contingencia c,
	motivo_contingencia m
where
	m.id_motivo_contingencia = c.id_motivo_contingencia
union
select
	null as nombre_sucursal,
	null as motivo_contingencia,
	null activar,
	null id_bodega
order by 
	id_bodega nulls last;

