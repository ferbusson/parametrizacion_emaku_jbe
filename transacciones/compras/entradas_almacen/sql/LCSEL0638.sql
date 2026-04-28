--Si el movimiento es false quiere decir que afecta cxp
--El id_cta que recibe corresponde a cuenta 2205 que depende de la temporada
INSERT INTO 
	cartera(
		nfactura,
		idtercero,
		id_cta,
		dcredito,
		neto_factura,
		total_factura,
		movimiento) 
VALUES
	('?',
	'?', --idtercero
	(SELECT id_cta FROM cuentas WHERE char_cta = '?'), -- id_cta
	COALESCE('?',0), --dcredito
	'?', --netofact
	'?', --vrpag
	false);