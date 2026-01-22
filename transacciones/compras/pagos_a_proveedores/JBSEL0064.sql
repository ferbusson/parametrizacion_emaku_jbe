SELECT
	char_cta,
	nombre||' - '||char_cta
FROM
	cuentas
WHERE
	--nombre IN ('TESORERIA','PUNTO DE PAGO') AND
	char_cta IN ('11100502','11100503','11100504','11100505','11100506','11100507','11053501','11053502') AND
	tipo IS FALSE
ORDER BY
	char_cta;