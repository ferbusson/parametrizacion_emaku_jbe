SELECT 
	g.id,
	g.nombre1
FROM
	general g,
	perfiles p
WHERE
	g.id = p.id AND
	p.tipo = '006' AND
	g.nombre1 ILIKE '%PEDI%'
ORDER BY
	g.nombre1;