INSERT INTO 
	datos_documento(
		ndocumento,
		efectivo,
		tcredito,
		cheque,
		consignacion,
		cambio,
		valor) 
VALUES('?',COALESCE('?',0.0),COALESCE('?',0.0),COALESCE('?',0.0),COALESCE('?',0.0),COALESCE('?',0.0),COALESCE('?',0.0));