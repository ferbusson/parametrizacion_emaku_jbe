SELECT
	'CUDE: '||cd.cufe AS cufe,
	'NumFac: '||COALESCE(rf.prefijo,d.codigo_tipo)||d.numero::BIGINT||E'\nFecFac: '||d.fecha::DATE||E'\nHoraFac: '||d.fecha::time||'-05:00'||E'\nNitFac: '||g.id_char||E'\nDocAdq: '||cd.docadq||E'\nValFac: '||to_char(cd.valfac,'999999990.00')||E'\nValIva: '||to_char(cd.valiva,'999999990.00')||E'\nValOtroIm: '||to_char(cd.valotroim,'999999990.00')||E'\nValTolFac: '||to_char(cd.valfacim,'999999990.00')||E'\nCUFE: '||cd.cufe||E'\nqr:URL='||rs.url_busqueda||cd.cufe AS qr,
	--CASE WHEN rf.prefijo IS NOT NULL THEN rf.prefijo||'-' ELSE '' END AS prefijo
	COALESCE(rf.prefijo,d.codigo_tipo)||'-' AS prefijo
FROM	
	cufe_documentos cd,
	registro_software rs,
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
	g.id=1 AND
	d.ndocumento=cd.ndocumento AND
	d.codigo_tipo='?' AND
	d.numero= LPAD('?',10,'0');