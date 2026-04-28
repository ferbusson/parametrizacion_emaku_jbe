SELECT
	td.codigo_tipo,
	CASE WHEN td.codigo_tipo LIKE 'G%' THEN 'FACTURA ELECTRONICA CREDITO ('||COALESCE(rf.prefijo,td.codigo_tipo)||')' 
	WHEN td.codigo_tipo LIKE 'Z%' THEN 'FACTURA ELECTRONICA CONTADO ('||COALESCE(rf.prefijo,td.codigo_tipo)||')' 
	WHEN td.codigo_tipo LIKE 'P%' THEN 'FACTURA CONTINGENCIA CONTADO ('||COALESCE(rf.prefijo,td.codigo_tipo)||')'
	WHEN td.codigo_tipo LIKE 'U%' THEN 'FACTURA CONTINGENCIA CREDITO ('||COALESCE(rf.prefijo,td.codigo_tipo)||')' END AS descripcion
FROM
	administracion_sucursales a,
	tipo_documento td,	
	documentos_standar dst,
	documentos_sucursales ds2,
	documentos_sucursales ds
LEFT OUTER JOIN
	(SELECT DISTINCT ON (tipo_doc)
		rf.tipo_doc,
		rf.prefijo
	FROM
		resolucion_facturacion rf
	ORDER BY
		rf.tipo_doc DESC,
		rf.id_resolucion_facturacion DESC) AS rf
ON
	ds.codigo_tipo = rf.tipo_doc
WHERE
	--a.id_bodega_ppal = '138' AND
	ds2.codigo_tipo = '?' and
	ds2.id_administracion_sucursales = ds.id_administracion_sucursales and
	a.id_administracion_sucursales = ds.id_administracion_sucursales AND
	ds.id_documento = dst.id_documento AND
	dst.nombre IN ('FCONTINGENCIAE','FELECTRONICAPOS','FCREDITO','FCONTINGENCIA') AND
	ds.codigo_tipo = td.codigo_tipo
ORDER BY
	dst.id_documento;