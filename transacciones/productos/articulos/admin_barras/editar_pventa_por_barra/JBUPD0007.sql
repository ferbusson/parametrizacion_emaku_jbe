DROP TABLE IF EXISTS aux_params;
CREATE TEMP TABLE aux_params AS
SELECT
	'?'::FLOAT8 AS pventa,
	'?'::FLOAT8 AS abanico,
	'?'::FLOAT8 AS base,
	'?'::CHARACTER(14) AS codigo;

UPDATE
	pventa
SET
	pventa = a.pventa
FROM	
	prod_serv ps,
	aux_params a
WHERE
	pventa.id_catalogo = 3 AND
    pventa.id_lista = 1 AND
	pventa.id_prod_serv = ps.id_prod_serv AND
	ps.codigo = a.codigo;


UPDATE
	pventa
SET
	pventa = a.abanico
FROM	
	prod_serv ps,
	aux_params a
WHERE
	pventa.id_catalogo = 3 AND
    pventa.id_lista = 2 AND
	pventa.id_prod_serv = ps.id_prod_serv AND
	ps.codigo = a.codigo;

UPDATE
	pventa
SET
	pventa = a.base
FROM	
	prod_serv ps,
	aux_params a
WHERE
	pventa.id_catalogo = 3 AND
    pventa.id_lista = 3 AND
	pventa.id_prod_serv = ps.id_prod_serv AND
	ps.codigo = a.codigo;

INSERT INTO 
	pventa(
		id_catalogo,
		id_prod_serv,
        id_lista,
		pventa)
SELECT
	3 as id_catalogo,
	foo.id_prod_serv,
    1 as id_lista,
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
		id_catalogo = 3
        and id_lista = 1) AS foo;


INSERT INTO 
	pventa(
		id_catalogo,
		id_prod_serv,
        id_lista,
		pventa)
SELECT
	3 as id_catalogo,
	foo.id_prod_serv,
    2 as id_lista,
	a.abanico
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
		id_catalogo = 3
        and id_lista = 2) AS foo;


INSERT INTO 
	pventa(
		id_catalogo,
		id_prod_serv,
        id_lista,
		pventa)
SELECT
	3 as id_catalogo,
	foo.id_prod_serv,
    3 as id_lista,
	a.base
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
		id_catalogo = 3
        and id_lista = 3) AS foo;