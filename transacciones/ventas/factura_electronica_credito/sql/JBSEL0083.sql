DROP TABLE IF EXISTS aux_params_g;
CREATE TEMP TABLE aux_params_g AS
SELECT
	'?'::INT AS id,
	'?'::VARCHAR AS nothing;

SELECT
	g.nombre_comercial
FROM
	aux_params_g a,
	"general" g 
WHERE
	a.id = g.id;