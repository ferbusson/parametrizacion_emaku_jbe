SELECT
	pv.pventa AS pventa2
FROM
	prod_serv p,
	pventa pv
WHERE
	p.id_prod_serv = pv.id_prod_serv AND
	pv.id_catalogo = 2 AND
	pv.id_lista = 1 AND
	p.codigo = '?'
