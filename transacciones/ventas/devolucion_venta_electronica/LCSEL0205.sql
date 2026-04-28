SELECT 
	c.char_cta,
	c.nombre,
	rd.base,
	rd.porcentaje,
	0.0,
	c.id_cta,
        0,
        '06'
FROM
	cuentas c,
	retenciones_documento rd,
	documentos d
WHERE
	d.ndocumento=rd.ndocumento AND
	c.id_cta=rd.id_cta AND
	c.char_cta ilike '135515%' AND
	d.codigo_tipo='?' AND
	d.numero=LPAD('?',10,'0');