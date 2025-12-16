--JBINS0015
DROP TABLE IF EXISTS aux_listado_precios;
CREATE TABLE aux_listado_precios AS
SELECT
        CAST('?' AS int) AS id_asiento_generico,
	CAST('?' AS float8) AS costo,
    trim('?'::text) as barra,
	CAST('?' AS float8) AS mostrador,
	CAST('?' AS float8) AS abanico,
	CAST('?' AS float8) AS base,
    CAST('?' AS integer) AS id_catalogo;
	

-- lista mostrador para cada catalogo
INSERT INTO
	pventa(
		id_catalogo,
		id_prod_serv,
		pventa,
        id_lista)
SELECT	
	id_catalogo,
	CURRVAL('prod_serv_id_prod_serv_seq'),
	mostrador,
    1 as id_lista
FROM
	aux_listado_precios;

-- lista abanico para cada catalogo
INSERT INTO
	pventa(
		id_catalogo,
		id_prod_serv,
		pventa,
        id_lista)
SELECT	
	id_catalogo,
	CURRVAL('prod_serv_id_prod_serv_seq'),
	abanico,
    2 as id_lista
FROM
	aux_listado_precios;

-- lista base para cada catalogo
INSERT INTO
	pventa(
		id_catalogo,
		id_prod_serv,
		pventa,
        id_lista)
SELECT	
	id_catalogo,
	CURRVAL('prod_serv_id_prod_serv_seq'),
	base,
    3 as id_lista
FROM
	aux_listado_precios;

