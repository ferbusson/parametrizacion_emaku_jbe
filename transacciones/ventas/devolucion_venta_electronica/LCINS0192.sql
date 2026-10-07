INSERT INTO 
	cartera(
		ncomprobante,
		idtercero,
		nfactura,
		abono_comprobante,
		id_cta) 
SELECT
	'?'::bigint as ncomprobante,
	CASE WHEN char_cta = '13050502' THEN 830 ELSE CAST('?' AS INTEGER) END as idtercero, -- para sistecredito se inserta el tercero de sistecredito
	'?'::bigint as nfactura,
	CAST('?' AS NUMERIC(20,2)) as abono_comprobante,
	id_cta
FROM 
	cuentas
WHERE 
	char_cta = '?';