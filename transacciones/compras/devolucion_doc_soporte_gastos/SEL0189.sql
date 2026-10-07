SELECT
	observacion
FROM
	obs_documento od ,
	documentos d
WHERE
	od.ndocumento=d.ndocumento AND
	codigo_tipo='?' AND
	d.numero=lpad('?',10,'0')