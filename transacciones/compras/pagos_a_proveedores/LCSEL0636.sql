DROP TABLE IF EXISTS aux_facturas_pagadas;
CREATE TABLE aux_facturas_pagadas
(
	char_cta CHARACTER(10),	
	valor_abono FLOAT8,
	total_descuento FLOAT8
);

INSERT INTO aux_facturas_pagadas (char_cta, valor_abono, total_descuento) VALUES 
?;
--('220525',410000)

SELECT
	c.char_cta,
	c.nombre,
	valor_abono AS debito,
	0.00 AS credito,
	NEXTVAL('tagdata') AS tag
FROM
	aux_facturas_pagadas a,
	cuentas c
WHERE
	a.char_cta = c.char_cta AND
	a.valor_abono > 0.00
UNION ALL
SELECT
	c.char_cta,
	c.nombre,
	0.00 AS debito,
	total_descuento AS credito,
	NEXTVAL('tagdata') AS tag
FROM
	aux_facturas_pagadas a,
	cuentas c
WHERE
	c.char_cta = '421040' AND	
	a.total_descuento > 0.00
ORDER BY
	char_cta;