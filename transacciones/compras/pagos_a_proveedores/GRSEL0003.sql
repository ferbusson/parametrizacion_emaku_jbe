SELECT
	char_cta,
	nombre||' - '||char_cta
FROM
	cuentas
WHERE
	--nombre IN ('TESORERIA','PUNTO DE PAGO') AND
	char_cta IN ('11053001','11053002') AND
	tipo IS FALSE
ORDER BY
	char_cta;