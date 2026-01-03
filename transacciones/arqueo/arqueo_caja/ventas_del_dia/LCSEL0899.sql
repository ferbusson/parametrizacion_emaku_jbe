SELECT 
	id_bodega,
	nombre
FROM
	(SELECT
        id_bodega_ppal||'-'||a.id_administracion_sucursales AS id_bodega,
        a.nombre,
        row_number() over (ORDER BY a.nombre) as id
    FROM
        administracion_sucursales a
	ORDER BY
		id_bodega) AS foo
ORDER BY
	id;
