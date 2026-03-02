DROP TABLE IF EXISTS aux_args_query;
CREATE TEMP TABLE aux_args_query AS
SELECT
	'?'::BIGINT AS ndocumento,
	'?'::INTEGER AS tercero,
	'?'::SMALLINT AS id_centrocosto,
    '?'::INTEGER AS id_bodega;
	
UPDATE
	libro_auxiliar AS l
SET
	id_tercero = 830 -- para sistecredito se pone el id_tercero de sistecredito
FROM
	aux_args_query a
WHERE
	l.ndocumento = a.ndocumento and
    l.id_cta = (select id_cta from cuentas where char_cta = '13050502');
