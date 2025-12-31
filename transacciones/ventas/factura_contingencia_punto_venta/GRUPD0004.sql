UPDATE
	info_documento
SET
	id_motivo_contingencia = foo.id_motivo_contingencia
FROM
	(SELECT
		'?'::BIGINT AS ndocumento,
		'?'::INTEGER AS id_motivo_contingencia) AS foo
WHERE
	info_documento.ndocumento = foo.ndocumento;