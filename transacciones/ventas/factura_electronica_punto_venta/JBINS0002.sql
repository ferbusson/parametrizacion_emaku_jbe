INSERT INTO cartera(nfactura,idtercero,dcredito,neto_factura,total_factura,movimiento,id_cta)
VALUES
	('?',
	 '?',
	  0,
	 '?',
	 '?',
	 false,
	 (select id from cuentas where char_cta= '233520' ))) --COMISION POR VENTAS 