SELECT
	u.login
FROM
	documentos d,
	info_documento i,
	usuarios u
WHERE
	d.ndocumento = i.ndocumento AND
	i.id_usuario = u.id_usuario AND
	d.codigo_tipo = '?' AND
	d.numero = LPAD('?',10,'0');