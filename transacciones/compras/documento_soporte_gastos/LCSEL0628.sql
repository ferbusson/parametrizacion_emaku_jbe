SELECT
	c.char_cta,
	l.detalle,
	l.debe,
	l.haber,
	current_timestamp
FROM
	documentos d,
	libro_auxiliar l,
	cuentas c
WHERE
	d.ndocumento=l.ndocumento AND
	l.detalle NOT ILIKE '%gravamen%' AND
	l.id_cta = c.id_cta AND
	d.codigo_tipo='?' AND
	d.numero=LPAD('?',10,'0')
ORDER BY
	c.char_cta;