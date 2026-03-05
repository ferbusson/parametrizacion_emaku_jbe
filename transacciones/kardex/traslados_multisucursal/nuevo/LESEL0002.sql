DROP TABLE IF EXISTS args_t;
CREATE TEMP TABLE args_t AS 
SELECT
	'?'::CHARACTER(14) AS codigo,
	'?'::FLOAT AS id_bodega;

SELECT
	foo.codigo,
	foo.ref_proveedor,
	SUBSTRING(foo.descripcion,1,42) AS descripcion,
	--CASE WHEN foo.id_bodega=143 THEN 100 ELSE SUM(COALESCE(inv.entrada,0))-SUM(COALESCE(inv.salida,0)) END AS disponible,
	SUM(COALESCE(inv.entrada,0))-SUM(COALESCE(inv.salida,0)) AS disponible,
	foo.color,
	foo.talla,
	foo.pventa,
	foo.id_prod_serv,
	foo.marca,
	foo.linea,
	SUBSTRING(foo.descripcion,1,60) AS descripcion_impr,
	SUBSTRING(foo.linea,1,14) AS linea_impr,
	SUBSTRING(foo.marca,1,14) AS marca_impr,
        '(  )' AS revisado, -- solo se usa en alistamiento de mercancia antes de despacho
	NEXTVAL('tagdata') AS tagdata
FROM
	(SELECT
		a.id_bodega,
		i.ref_proveedor,
		i.nombre AS descripcion,
		c.descripcion AS color,
		t.talla,
		pv.pventa,
		p.id_prod_serv,
		p.codigo,
		m.descripcion AS marca,
		l.descripcion AS linea
	FROM
		pventa pv,
		item i,
		prod_serv p,
		tallas t,
		colores c,
		args_t a,
		marcas m,
		linea l
	WHERE
		i.id_marca = m.id_marca AND
		i.id_linea = l.id_linea AND
		pv.id_prod_serv=p.id_prod_serv AND
		pv.id_catalogo=1 and
		pv.id_lista = 1 and
		p.id_item=i.id_item AND
		p.id_talla=t.id_talla AND
		p.id_color=c.id_color AND
		p.codigo=a.codigo) AS foo
LEFT OUTER JOIN
	(SELECT
		i.id_prod_serv,
		i.id_bodega,
		entrada,
		salida
	FROM
		inventarios i,
	 	prod_serv p,
		args_t a
	WHERE
		i.id_bodega::FLOAT = a.id_bodega AND
		i.id_prod_serv = p.id_prod_serv AND
		p.codigo = a.codigo) AS inv
ON
	inv.id_prod_serv = foo.id_prod_serv
GROUP BY
	foo.ref_proveedor,
	foo.color,
	foo.descripcion,
	foo.talla,
	foo.pventa,
	foo.id_prod_serv,
	foo.id_bodega,
	foo.codigo,
	foo.marca,
	foo.linea;