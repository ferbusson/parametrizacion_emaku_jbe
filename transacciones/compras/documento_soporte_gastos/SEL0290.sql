SELECT
	t.fecha,
	c.nombre||' '||c.char_cta,
	TRIM(g.nombre1||' '||g.nombre2||' '||g.apellido1||' '||g.apellido2||' '||g.razon_social) as nombre,
	valor
FROM
	transferencias t,
	cuentas c,
	documentos d,
	general g
WHERE 
	t.id_cta=c.id_cta AND 
	g.id=t.id_banco AND
	d.ndocumento=t.ndocumento AND 
	d.codigo_tipo='?' 
	AND d.numero=LPAD('?',10,'0')
