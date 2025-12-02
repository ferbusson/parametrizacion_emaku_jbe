SELECT
	pv.pventa AS pventa1
FROM
	prod_serv p,
	pventa pv
WHERE
	p.id_prod_serv = pv.id_prod_serv AND
	pv.id_catalogo = 1 AND
	p.codigo = '?'
