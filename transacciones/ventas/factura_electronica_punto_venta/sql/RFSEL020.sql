SELECT 
	CASE WHEN
		a.regimen = TRUE
	THEN
		'RESOLUCION DIAN No. '||numero 
	ELSE
		''
	END AS numero
FROM 
	resolucion_facturacion r,
	administracion_sucursales a,
	documentos_sucursales ds
WHERE 
	r.tipo_doc = ds.codigo_tipo AND
	ds.id_administracion_sucursales = a.id_administracion_sucursales AND
	id_resolucion_facturacion 
IN 
	(SELECT 
		max(id_resolucion_facturacion)
	FROM 
		(SELECT
			id_resolucion_facturacion,
			tipo_doc,
			desde::bigint AS desde,
			hasta::bigint AS hasta
		FROM
			resolucion_facturacion rf) AS rf,
		documentos d
	WHERE 
		d.codigo_tipo=tipo_doc AND
		d.numero::bigint+1 BETWEEN rf.desde AND rf.hasta AND
		tipo_doc='?');