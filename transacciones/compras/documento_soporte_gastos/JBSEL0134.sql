--JBSEL0134
SELECT 
	c.codigo
FROM 
	documentos d,
	centrocosto c,
	libro_auxiliar l
WHERE 
	l.ndocumento=d.ndocumento AND 
	l.id_centrocosto IS NOT NULL AND
	l.id_centrocosto = c.id_centrocosto AND
	d.codigo_tipo='?' AND 
	d.numero=LPAD('?',10,'0')
LIMIT 1;