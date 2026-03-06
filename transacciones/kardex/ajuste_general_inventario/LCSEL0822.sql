-- consulta bodegas de la sucursal, solo en el caso de estar en la principal adiciona bodegas online

DROP TABLE IF EXISTS aux_params_query;
CREATE TEMP TABLE aux_params_query AS
SELECT 
	g.id,
	g.nombre1
FROM
	general g,
	administracion_sucursales a
WHERE
	g.id = a.id_bodega_ppal;
	

SELECT distinct
	id,
	nombre1
FROM
	aux_params_query
ORDER BY
	id;