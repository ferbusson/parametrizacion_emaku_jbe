SELECT
	g.nombre1 AS bodega_sep
FROM
	administracion_sucursales a,
	general g
WHERE
	a.id_bodega_sep = g.id AND
	a.nombre = '?';