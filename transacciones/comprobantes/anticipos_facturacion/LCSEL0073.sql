SELECT 
	denominacion,
	cantidad
FROM 
	cheques_sodexobigpass c,
	documentos d
WHERE
	d.ndocumento = c.ndocumento AND
	codigo_tipo = '?' AND
	d.numero=LPAD('?',10,'0') AND
	id_sodexobigpass = 2;