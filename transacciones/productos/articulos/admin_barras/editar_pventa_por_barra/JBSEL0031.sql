SELECT
	pv.pventa AS pventa3_base
FROM
	prod_serv p,
	pventa pv
WHERE
	p.id_prod_serv = pv.id_prod_serv AND
	pv.id_catalogo = 3 AND
    pv.id_lista = 3 AND
	p.codigo = '?'
