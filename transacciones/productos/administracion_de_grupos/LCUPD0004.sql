DROP TABLE IF EXISTS aux;
CREATE TEMP TABLE aux AS 
SELECT
	CASE WHEN linea = '' THEN NULL ELSE linea END AS linea,
	CASE WHEN grupo = '' THEN NULL ELSE grupo END AS grupo,
	CASE WHEN sgrupo = '' THEN NULL ELSE sgrupo END AS sgrupo,
	codigo,
	bol
FROM
	(SELECT
		'?'::VARCHAR AS linea,
		'?'::VARCHAR AS grupo,
		'?'::VARCHAR AS sgrupo,
		'?'::CHARACTER(14) AS codigo,
		'?'::BOOLEAN AS bol) AS foo;

UPDATE 
	item
SET
	id_linea=a.linea::SMALLINT,
	id_grupo=a.grupo::SMALLINT,
	id_sgrupo=a.sgrupo::SMALLINT
FROM
	aux a,
	prod_serv ps
WHERE
	a.codigo = ps.codigo AND
        ps.id_item=item.id_item AND
        a.bol;

--

UPDATE 
	item
SET
	id_linea = -1
FROM
	aux a,
	prod_serv ps
WHERE
	a.codigo = ps.codigo AND
        ps.id_item=item.id_item AND
        a.bol IS FALSE AND
        a.grupo IS NULL AND
        a.sgrupo IS NULL;

--

UPDATE 
	item
SET
	id_grupo = NULL
FROM
	aux a,
	prod_serv ps
WHERE
	a.codigo = ps.codigo AND
        ps.id_item=item.id_item AND
        a.bol IS FALSE AND
        a.linea IS NOT NULL AND
        a.sgrupo IS NULL;

--

UPDATE 
	item
SET
	id_sgrupo = NULL
FROM
	aux a,
	prod_serv ps
WHERE
	a.codigo = ps.codigo AND
        ps.id_item=item.id_item AND
        a.bol IS FALSE;