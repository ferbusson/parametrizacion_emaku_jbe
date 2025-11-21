SELECT 
	co.fecha,
	c.nombre||' '||c.char_cta AS cuenta,
	co.valor
FROM 
	consignaciones co,
	cuentas c,
	documentos d
WHERE 
	co.id_cta=c.id_cta AND 
	d.ndocumento=co.ndocumento AND 
	d.codigo_tipo='?' AND 
	d.numero=LPAD('?',10,'0');