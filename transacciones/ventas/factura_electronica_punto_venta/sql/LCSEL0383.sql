SELECT
	g.id_char||'; '||g.razon_social||'; '||rf.prefijo||d.numero::BIGINT||'; 01; JAVIER BENAVIDES ERAZO SAS' AS subject,
	rf.prefijo||(d.numero::bigint) AS numero
FROM
	documentos d,
	resolucion_documento rd,
	resolucion_facturacion rf,
	general g
WHERE
	d.ndocumento = '?' AND
	d.ndocumento = rd.ndocumento AND
	rd.id_resolucion_facturacion = rf.id_resolucion_facturacion AND
	g.id = 1;