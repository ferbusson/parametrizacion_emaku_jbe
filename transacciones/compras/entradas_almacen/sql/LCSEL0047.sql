SELECT
	c.char_cta,
	cxp.nombre
FROM
	clase_cxp cxp,
	cuentas c
WHERE
	cxp.id_cta_cxp = c.id_cta
ORDER BY
	nombre;