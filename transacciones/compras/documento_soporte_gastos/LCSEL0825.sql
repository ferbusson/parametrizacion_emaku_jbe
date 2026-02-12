SELECT
	ps.id_prod_serv
FROM	
	asientos_genericos a,
	prod_serv ps,
	item i
WHERE
	ps.id_asiento_generico = a.id_asiento_generico AND
	ps.id_tipo_prod_serv = '002' AND -- servicios
	ps.id_item = i.id_item AND
	i.id_sgrupo = 693 AND -- documento equivalente grupo: documento equivalente linea: servicios
	a.id_asiento_generico = '?';