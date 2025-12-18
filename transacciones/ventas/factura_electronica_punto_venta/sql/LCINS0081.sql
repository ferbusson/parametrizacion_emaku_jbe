INSERT INTO 
	cartera(
		nfactura,
		idtercero,
		dcredito,
		neto_factura,
		total_factura,
		movimiento,
		id_cta) 
VALUES
	('?','?',COALESCE('?',0),'?','?',true,(SELECT id_cta FROM cuentas WHERE char_cta = '?'));