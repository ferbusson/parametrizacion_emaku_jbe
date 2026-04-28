SELECT 
	c.char_cta,
	c.nombre,
	rd.base,
	rd.porcentaje
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