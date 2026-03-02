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
	'?',
	CASE WHEN char_cta = '13050502' THEN 830 ELSE CAST('?' AS INTEGER) END, -- para sistecredito se inserta el tercero de sistecredito
	COALESCE(CAST('?' AS NUMERIC), 0),
	CAST('?' AS NUMERIC),
	CAST('?' AS NUMERIC),
	true,
	id_cta
FROM cuentas
WHERE char_cta = '?';