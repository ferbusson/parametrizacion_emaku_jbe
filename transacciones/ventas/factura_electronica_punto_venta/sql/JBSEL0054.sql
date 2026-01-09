/*SELECT
	CASE WHEN 
		total_remisiones IS NOT NULL AND 
		total_remisiones != '' AND 
		total_remisiones::FLOAT8 > 0.0 
	THEN 
		7015::CHARACTER(4) 
	ELSE 
		id_bodega_ppal::CHARACTER(3) 
	END AS id_bodega_ppal
FROM
	(*/SELECT 
		id_bodega_sep--,
		--'interrogacion'::VARCHAR AS total_remisiones lust
	FROM 
		administracion_sucursales a,
		documentos_sucursales ds
	WHERE 
		a.id_administracion_sucursales = ds.id_administracion_sucursales AND
		ds.codigo_tipo='?';
		/*) AS foo;*/