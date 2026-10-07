SELECT
	COALESCE(rf.prefijo,d.codigo_tipo)||'-'||d.numero::BIGINT AS numeroea
FROM
	documentos d
LEFT OUTER JOIN
	resolucion_documento rd
ON
	d.ndocumento = rd.ndocumento
LEFT OUTER JOIN
	resolucion_facturacion rf
ON
	rd.id_resolucion_facturacion = rf.id_resolucion_facturacion
WHERE
	d.codigo_tipo = '?' AND
	d.numero = LPAD('?',10,'0');
