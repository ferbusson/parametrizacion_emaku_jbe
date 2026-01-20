--JBINS0010

INSERT INTO
	cartera(
        ncomprobante,
		idtercero,
		dcredito,
		abono_comprobante,
		movimiento,
		id_cta) 
SELECT
    CAST('?' AS INT8) AS ncomprobante,    
	id,
	0,
	valor,
	TRUE,
	(select id_cta from cuentas where char_cta = '28050501' limit 1)
FROM
	(SELECT 
		'?'::INT8 AS id,
		CAST('?' AS INT8) AS id_centrocosto,	
		CAST('?' AS float8) AS valor) AS foo;
