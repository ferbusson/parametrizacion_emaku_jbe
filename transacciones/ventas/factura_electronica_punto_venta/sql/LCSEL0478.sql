DROP TABLE IF EXISTS aux_params;
CREATE TEMP TABLE aux_params AS
SELECT
	'?'::INT AS id,
	'?'::VARCHAR AS nothing;

SELECT
	foo.id_direccion
FROM
	aux_params a,
	(SELECT 
		id,
		MAX(id_direccion) AS id_direccion
	FROM
		direcciones
	GROUP BY
		id) AS foo
WHERE
	a.id = foo.id;