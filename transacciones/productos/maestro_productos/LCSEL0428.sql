SELECT
	COALESCE(pv.pventa,0) AS pventa3,
	COALESCE(ag.descripcion,'Sin asiento contable') AS asiento_generico,
	ps.iva
FROM
	prod_serv ps
LEFT OUTER JOIN
	asientos_genericos ag
ON
	ps.id_asiento_generico = ag.id_asiento_generico
LEFT OUTER JOIN
	pventa pv
ON
	ps.id_prod_serv = pv.id_prod_serv AND
	pv.id_catalogo = 3
	and pv.id_lista = 1
WHERE	
	ps.codigo = '?';