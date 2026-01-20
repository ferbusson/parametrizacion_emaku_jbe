/*241-P-CARRERA21
243-P-CCARPINTE
245-P-AMERICAS*/
--JBSEL0043
SELECT DISTINCT
	codigo,
	ref_prov,
	descripcion,
	COALESCE(sdo,0) AS sdo,
	linea,
	grupo,
	subgrupo,
	marca,
	submarca,
	pventa1,
	pventa2,
	foo.id_prod_serv
FROM
	(SELECT
	        p.codigo,
		TRIM(i.ref_proveedor) AS ref_prov,
		TRIM(i.nombre) AS descripcion,
		l.descripcion AS linea,
		g.descripcion AS grupo,
		sg.descripcion AS subgrupo,
		m.descripcion as marca,
		sm.descripcion AS submarca,
		pv1.pventa1,
		pv2.pventa2,
		p.id_prod_serv
	FROM
		marcas m,
		linea l,
		grupo g,
		sgrupo sg,
		prod_serv p,
		(SELECT id_prod_serv,pventa AS pventa1 FROM pventa WHERE id_catalogo=1 AND id_lista = 1) AS pv1,
		(SELECT id_prod_serv,pventa AS pventa2 FROM pventa WHERE id_catalogo=2 AND id_lista = 1) AS pv2,
		item i
	LEFT OUTER JOIN
		submarcas sm
	ON
		i.id_submarca = sm.id_submarca
	WHERE
		i.id_linea = l.id_linea AND
		i.id_grupo = g.id_grupo AND
		i.id_sgrupo = sg.id_sgrupo AND
		m.id_marca=i.id_marca AND
		p.id_item=i.id_item AND
		p.id_prod_serv=pv1.id_prod_serv AND
		p.id_prod_serv=pv2.id_prod_serv AND
		p.codigo = '?' ) AS foo
LEFT OUTER JOIN
	(SELECT 
		id_prod_serv,
		SUM(COALESCE(entrada,0))-SUM(COALESCE(salida,0)) AS sdo 
	FROM 
		inventarios i
	WHERE
		i.id_bodega=245
	GROUP BY
		i.id_prod_serv) AS sdo
ON
	sdo.id_prod_serv = foo.id_prod_serv
ORDER BY
	descripcion;