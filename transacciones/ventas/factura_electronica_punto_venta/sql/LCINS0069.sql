/*DROP TABLE IF EXISTS aux_error;
CREATE TEMP TABLE aux_error AS
SELECT
	1
FROM
	(SELECT
		error_text('Error, Centro de costo registrado más de una vez, solo puede existir un registro'),
		id_centrocosto,
		count(1)
	FROM	
		auxiliar_plataformas_virtuales
	GROUP BY
		id_centrocosto
	HAVING
		COUNT(1)>1) AS f;
*/
/*
DROP TABLE IF EXISTS aux_error;
CREATE TEMP TABLE aux_error AS
SELECT
	1
FROM
	(SELECT
		error_text('Error, Bodega registrada más de una vez, solo puede existir un registro'),
		id_bodega,
		count(1)
	FROM	
		auxiliar_plataformas_virtuales
	GROUP BY
		id_bodega
	HAVING
		COUNT(1)>1) AS f;
*/

DROP TABLE IF EXISTS aux_error;
CREATE TEMP TABLE aux_error AS
SELECT
	1
FROM
	(SELECT
		error_text('Error, Cuenta registrada más de una vez, solo puede existir un registro'),
		id_cta,
		count(1)
	FROM	
		auxiliar_plataformas_virtuales
	GROUP BY
		id_cta
	HAVING
		COUNT(1)>1) AS f;

		
DROP TABLE IF EXISTS aux_error;
CREATE TEMP TABLE aux_error AS
SELECT
	1
FROM
	(SELECT
		error_text('Error, falta la bodega, cuenta o lista de precios en uno de los registros, revise por favor'),
		id_centrocosto
	FROM	
		auxiliar_plataformas_virtuales
	WHERE
		id_bodega IS NULL OR
		id_cta IS NULL OR
		id_catalogo_pventa IS NULL) AS f;

DELETE FROM 
	plataformas_virtuales;

INSERT INTO
	plataformas_virtuales(
		id_centrocosto,
		id_bodega,
		id_cta,
		id_catalogo_pventa)
SELECT
	id_centrocosto,
	id_bodega,
	id_cta,
	id_catalogo_pventa
FROM
	auxiliar_plataformas_virtuales;

DROP TABLE IF EXISTS auxiliar_plataformas_virtuales;