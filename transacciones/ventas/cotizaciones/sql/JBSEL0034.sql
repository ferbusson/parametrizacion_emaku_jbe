--JBSEL0034
SELECT 
	foo2.nombre,
	foo2.descripcion,
	foo2.id_char,
	foo2.id 
FROM 
	(SELECT 
		foo.nombre,
		e.descripcion,
		foo.id_char,
		foo.id 
	FROM 
		(SELECT 
			TRIM(g.nombre1||' '||g.nombre2||' '||g.apellido1||' '||g.apellido2||' '||g.razon_social) as nombre,
			g.id_char,
			g.id 
		FROM 
			general g,
			perfiles p,
			tipo_general t 
		WHERE 
			g.id=p.id AND 
			p.tipo=t.tipo AND 
			t.tipo='002') AS foo 
	LEFT OUTER JOIN 
		establecimiento e 
	ON 
	foo.id=e.id) AS foo2,
	documentos doc,
	tercero_def td
WHERE 
	doc.estado='true' AND
	doc.codigo_tipo='?' AND 
	doc.numero=LPAD('?',10,'0') AND 
	doc.ndocumento=td.ndocumento AND 
	td.id=foo2.id