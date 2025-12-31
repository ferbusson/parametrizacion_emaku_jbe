SELECT 
	g.id,
	g.nombre1
FROM
	general g
WHERE
	--g.id IN (912,914,916,918,920,1250,1251,1252,138) AND
	g.id IN (731,241,243,245,138) AND
	g.id::FLOAT NOT IN ('?')
ORDER BY
	g.nombre1;