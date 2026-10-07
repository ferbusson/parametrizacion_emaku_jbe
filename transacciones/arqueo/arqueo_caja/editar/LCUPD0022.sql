DROP TABLE IF EXISTS aux_args_editar;
CREATE TEMP TABLE aux_args_editar AS
SELECT
	'?'::BIGINT AS ndocumento,
	'?'::TEXT AS observacion;

UPDATE
	obs_documento
SET
	observacion = a.observacion
FROM	
	aux_args_editar a
WHERE
	obs_documento.ndocumento = a.ndocumento;

INSERT INTO
	obs_documento
		(ndocumento,
		observacion)
SELECT
	a.ndocumento,
	a.observacion
FROM
	aux_args_editar a,
	(SELECT
		ndocumento
	FROM
		aux_args_editar
	EXCEPT
	SELECT
		ndocumento
	FROM
		obs_documento) AS foo
WHERE
	foo.ndocumento = a.ndocumento;