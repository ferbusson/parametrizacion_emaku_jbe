SELECT 
	g.id AS id_tercero_banco
FROM 
	tcredito t,
	general g
WHERE
	g.id = t.id_tercero_banco AND
	t.id_tcredito::VARCHAR = '?';