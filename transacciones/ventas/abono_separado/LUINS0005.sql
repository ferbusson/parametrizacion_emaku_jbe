INSERT INTO
	cartera(
		nfactura,
		idtercero,
		dcredito,
		neto_factura,
		total_factura,
		movimiento,
		id_cta) 
SELECT
	CAST('?' AS INT8) AS ndocumento,
	id,
	0,
	valor,
	valor,
	TRUE,
	4209
FROM
	(SELECT 
		CAST('?' AS INT8) AS id_centrocosto,	
		'?'::INT8 AS id,
		CAST('?' AS float8) AS valor) AS foo;
