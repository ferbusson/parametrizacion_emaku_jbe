INSERT INTO 
	datos_documento(
		ndocumento,
		efectivo,
		tcredito,
		cheque,
		consignacion,
		anticipo,
		cambio,
		valor,
		trm,
		instrumento_no_definido) 
SELECT
	ndocumento,
	efectivo,
	tcredito + tarjetamanualyparcial,
	cheque,
	consignacion,
	anticipo,
	cambio,
	valor,
	trm,
	puntosredimidosenpesos
FROM
	(SELECT
		'?'::BIGINT AS ndocumento,
		COALESCE('?',0.0) AS efectivo,
		COALESCE('?',0.0) AS tcredito,
		COALESCE('?',0.0) AS cheque,
		COALESCE('?',0.0) AS consignacion,
		COALESCE('?',0.0) AS cambio,
		COALESCE('?',0.0) AS valor,
		COALESCE('?',0.0) AS trm,
		COALESCE('?',0.0) AS tarjetamanualyparcial,
		COALESCE('?',0.0) AS anticipo,
		COALESCE('?',0.0) AS puntosredimidosenpesos
		) AS foo;