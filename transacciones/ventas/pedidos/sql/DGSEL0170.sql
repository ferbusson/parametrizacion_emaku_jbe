DROP TABLE IF EXISTS arg_barra_obs;
CREATE TEMP TABLE arg_barra_obs AS
SELECT
	'?'::VARCHAR AS clave;

DROP TABLE IF EXISTS valid_longitud;
CREATE TEMP TABLE valid_longitud AS
SELECT
	1
FROM
	(SELECT
		error_text('La palabra clave debe ser mayor a 2 caracteres')
	FROM
		arg_barra_obs
	WHERE
		length(clave)<=2 AND
		clave != '%') AS f;

SELECT 
	p.codigo,
	p.codigo||' - '||' '||i.ref_proveedor||' '||i.nombre||' - '||ma.descripcion AS descripcion
FROM 
	item i,
	marcas ma,
	arg_barra_obs a,
	prod_serv p
WHERE 
	ma.id_marca = i.id_marca AND
	p.id_item = i.id_item AND
	(i.ref_proveedor ILIKE '%'||a.clave||'%' OR 
	(COALESCE(i.ref_proveedor,'')||COALESCE(i.nombre,'')||COALESCE(ma.descripcion,'')||COALESCE(p.descripcion,'')||COALESCE(p.codigo,'')) ILIKE '%'||a.clave||'%') AND
	p.estado=true
ORDER BY
	ma.descripcion||' '||i.nombre;