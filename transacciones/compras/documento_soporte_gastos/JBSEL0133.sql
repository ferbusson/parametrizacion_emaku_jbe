--JBSEL0133
SELECT
	c.char_cta,
	l.detalle,
	l.haber as debe,
	l.debe as haber,	
	current_timestamp as tagdata,
	'NULL' as tercero,
	l.id_cta,
	0 as condicion,
	c.nombre,
	'NULL' as vk,
    CASE WHEN pc.edocumento THEN 'TRUE' ELSE 'FALSE' END AS edocumento,
    CASE WHEN pc.centro THEN 1 ELSE 0 END AS cc,
    CASE WHEN pc.scentro THEN 1 ELSE 0 END AS sc,
    coalesce(l.ndocumento_enlace::VARCHAR,'NULL') as ndocumento_enlace  
FROM
	documentos d,
	libro_auxiliar l,
	cuentas c,
	perfil_cta pc
WHERE
	d.ndocumento=l.ndocumento AND
	l.detalle NOT ILIKE '%gravamen%' AND
	l.id_cta = c.id_cta and
	c.id_cta = pc.id_cta AND
	d.codigo_tipo='?' AND
	d.numero=LPAD('?',10,'0')
ORDER BY
	l.orden;