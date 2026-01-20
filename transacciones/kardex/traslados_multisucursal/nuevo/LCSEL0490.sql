SELECT 
	g.id,
	g.nombre1
FROM
	general g
WHERE
	g.id = ?
ORDER BY
	g.id;