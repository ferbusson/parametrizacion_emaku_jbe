SELECT 
	g.id,
	g.nombre1
FROM
	general g,
	perfiles p
WHERE
	g.id = p.id AND
	g.id IN (138,241,243,245,140) AND
	p.tipo = '006' AND
	g.nombre1 NOT ILIKE '%SEP%'
UNION
SELECT
	-1 AS id,
	'TODAS'
ORDER BY
	id;