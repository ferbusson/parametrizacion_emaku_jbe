SELECT
	COALESCE(rf.prefijo,d2.codigo_tipo)||'-'||d2.numero::BIGINT AS numeroea
FROM
	documentos d,
	info_documento i,
	documentos d2
LEFT OUTER JOIN
	resolucion_documento rd
ON
	d2.ndocumento = rd.ndocumento
LEFT OUTER JOIN
	resolucion_facturacion rf
ON
	rd.id_resolucion_facturacion = rf.id_resolucion_facturacion
WHERE
	d.ndocumento = i.ndocumento AND
	i.rf_documento = d2.ndocumento AND
	d.codigo_tipo = '?' AND
	d.numero = LPAD('?',10,'0');