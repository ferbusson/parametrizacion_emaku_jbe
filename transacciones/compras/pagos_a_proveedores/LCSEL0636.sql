DROP TABLE IF EXISTS aux_facturas_pagadas;
CREATE TABLE aux_facturas_pagadas
(
	char_cta CHARACTER(10),	
	valor_abono FLOAT8,
	nfactura bigint,
	total_descuento FLOAT8
);

INSERT INTO aux_facturas_pagadas (char_cta, valor_abono, nfactura, total_descuento) VALUES 
?;
--('220525',410000,6260,0)

SELECT
	c.char_cta,
	c.nombre,
	d.codigo_tipo || '-' || d.numero::BIGINT ||
            CASE 
                WHEN i.ex_documento IS NOT NULL 
                     AND btrim(i.ex_documento) <> '' 
                THEN '|' || i.ex_documento 
                ELSE '' 
            END as factura,
	valor_abono+coalesce(total_descuento,0) AS debito,
	0.00 AS credito,
	NEXTVAL('tagdata') AS tag,
	(select get_codigo_centrocosto(a.nfactura)) as centrocosto
FROM
	cuentas c,
	aux_facturas_pagadas a,
	documentos d,
	info_documento i
where
	a.nfactura = d.ndocumento and
	d.ndocumento = i.ndocumento AND
	a.char_cta = c.char_cta AND
	a.valor_abono > 0.00
UNION ALL
SELECT
	c.char_cta,
	c.nombre,
	'--' as factura,
	0.00 AS debito,
	total_descuento AS credito,
	NEXTVAL('tagdata') AS tag,
	(select get_codigo_centrocosto(a.nfactura)) as centrocosto
FROM
	aux_facturas_pagadas a,
	cuentas c
WHERE
	c.char_cta = '42104001' AND	
	a.total_descuento > 0.00
ORDER BY
	char_cta;