DROP TABLE IF EXISTS aux_args_query;
CREATE TEMP TABLE aux_args_query AS
SELECT
	'?'::BIGINT AS ndocumento,
	'?'::INTEGER AS tercero,
	'?'::SMALLINT AS id_centrocosto;
	
UPDATE
	libro_auxiliar AS l
SET
	id_centrocosto = a.id_centrocosto
FROM
	aux_args_query a
WHERE
	l.ndocumento = a.ndocumento;
	
UPDATE
	libro_auxiliar_niifs AS l
SET
	id_centrocosto = a.id_centrocosto
FROM
	aux_args_query a
WHERE
	l.ndocumento = a.ndocumento;