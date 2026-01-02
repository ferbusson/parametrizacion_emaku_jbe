SELECT
	g.id_char||'; '||g.razon_social||'; '||COALESCE(rf.prefijo,d.codigo_tipo)||d.numero::BIGINT||'; 91; JAVIER BENAVIDES ERAZO SAS' AS subject,
	COALESCE(rf.prefijo,d.codigo_tipo)||(d.numero::bigint) AS numero
FROM
	general g,
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
	d.ndocumento = '?' AND	
	g.id = 1;