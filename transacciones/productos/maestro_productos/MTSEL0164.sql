SELECT
	p.pventa
FROM
	pventa p,
	prod_serv ps
WHERE
	ps.id_prod_serv = p.id_prod_serv AND
	p.id_catalogo = 1 AND
	p.id_lista = 1 AND
	ps.codigo = '?'
