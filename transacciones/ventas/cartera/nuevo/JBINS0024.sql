INSERT INTO 
	datos_documento(
		ndocumento,
		efectivo,
		tcredito,
		cheque,
		consignacion,
		anticipo,
		cambio,
		valor)		
SELECT
	ndocumento,
	efectivo,
	tcredito,
	cheque,
	consignacion,
	anticipo,
	cambio,
	valor
FROM
	(SELECT
		'?'::BIGINT AS ndocumento,
		COALESCE('?',0.0) AS efectivo,
		COALESCE('?',0.0) AS tcredito,
		COALESCE('?',0.0) AS cheque,
		COALESCE('?',0.0) AS consignacion,
		COALESCE('?',0.0) AS cambio,
		COALESCE('?',0.0) AS valor,
		COALESCE('?',0.0) AS anticipo) AS foo;