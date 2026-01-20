SELECT 
	g.id,
	g.nombre1
FROM
	general g,
	perfiles p
WHERE
	g.id = p.id AND
	p.tipo = '006' AND
	(g.nombre1 like '%PRINCIPAL%' or
	g.nombre1 like '%21%' or
	g.nombre1 like '%15%' or
	g.nombre1 ilike '%casa%') AND
	g.nombre1 NOT ILIKE '%SEP%' /*AND
	(g.id_char LIKE '%AMERI%'OR
	g.id_char LIKE '%BODEGA%')*/
ORDER BY
	g.id;