SELECT
	'BODEGA: '||COALESCE(g.nombre1,'SIN MOV EN INVENTARIOS') AS bodega,
	SUM(COALESCE(entrada,0))-SUM(COALESCE(salida,0)) AS saldo
FROM	
	prod_serv ps
LEFT OUTER JOIN
	inventarios i
ON
	ps.id_prod_serv = i.id_prod_serv AND
	--i.id_bodega IN (138,1250,1251,1252,916,920)
	i.id_bodega IN (138,241,243,245)
LEFT OUTER JOIN
	documentos d
ON
	i.ndocumento = d.ndocumento AND
	d.estado
LEFT OUTER JOIN
	general g
ON
	i.id_bodega = g.id
WHERE	
	ps.codigo = '?'
GROUP BY
	'BODEGA: '||COALESCE(g.nombre1,'SIN MOV EN INVENTARIOS')
ORDER BY
	bodega;