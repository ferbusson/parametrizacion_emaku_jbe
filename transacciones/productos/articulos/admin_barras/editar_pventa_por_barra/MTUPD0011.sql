DROP TABLE IF EXISTS aux_params;
CREATE TEMP TABLE aux_params AS
SELECT
	'?'::FLOAT8 AS pventa,
	'?'::CHARACTER(14) AS codigo;

UPDATE
	pventa
SET
	pventa = a.pventa
FROM	
	prod_serv ps,
	aux_params a
WHERE
	pventa.id_catalogo = 2 AND
	pventa.id_prod_serv = ps.id_prod_serv AND
	ps.codigo = a.codigo;

INSERT INTO 
	pventa(
		id_catalogo,
		id_prod_serv,
		pventa)
SELECT
	2 as id_catalogo,
	foo.id_prod_serv,
	a.pventa
FROM
	aux_params a,
	(SELECT
		ps.id_prod_serv
	FROM
		prod_serv ps,
		aux_params a
	WHERE
		ps.codigo = a.codigo
	EXCEPT
	SELECT
		id_prod_serv
	FROM
		pventa
	WHERE
		id_catalogo = 2) AS foo;