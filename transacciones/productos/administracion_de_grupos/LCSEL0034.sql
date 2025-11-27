SELECT
	d.ndocumento,
	d.codigo_tipo||d.numero||'---'||COALESCE(i.ex_documento,'')
FROM
	documentos d,
	info_documento i
WHERE
	d.ndocumento = i.ndocumento AND
	d.codigo_tipo = 'TC' AND
	d.fecha >= CURRENT_DATE - 15;