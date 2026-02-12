SELECT
	char_cta,
	nombre||' - '||char_cta
FROM
	cuentas
WHERE
	--nombre IN ('TESORERIA','PUNTO DE PAGO') AND
	char_cta IN (
		'11100502', -- bancolombia 3022
		'11100504', -- banco agrario
		'11100505', -- davivienda 4585
		'11100507', -- banco bogota
		'11053502', -- banco caja
		'21051004', -- credito virtual bancolombia
		'21051006', -- tarjeta credito bancolombia
		'21051008', -- tarjeta credito bogota
		'21051009' -- tarjeta credito davivienda
		) AND
	tipo IS FALSE
ORDER BY
	char_cta;