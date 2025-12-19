SELECT 
	TRIM(foo.nombre) AS nombre,
	TRIM(e.descripcion) AS descripcion,
	foo.id_char,
	foo.id,
	foo.id_regimen,
	TRIM(foo.regimen) AS regimen,
	foo.id_catalogo,
	TRIM(foo.catalogo) AS catalogo,
    foo.ndocumento
FROM 
	(SELECT TRIM(g.nombre1||' '||g.nombre2||' '||g.apellido1||' '||g.apellido2||' '||g.razon_social) as nombre,
		g.id_char,
		g.id,
		pt.id_regimen,
		r.descripcion AS regimen,
		pt.id_catalogo,
		c.nombre AS catalogo,
	    doc.ndocumento
	FROM 
		documentos doc,
		info_documento id,
		general g,
		perfiles p,
		perfil_tercero pt,
		regimenes r,
		tercero_def td
	left outer join
		catalogo_pventa c 
	on
		td.id_catalogo = c.id_catalogo
	WHERE 
		g.id=p.id AND 
		p.tipo='002' AND 
		pt.id=g.id AND 
		pt.id_regimen=r.id_regimen AND 
		doc.codigo_tipo='?' AND
		doc.numero=LPAD('?',10,'0') AND 
		doc.ndocumento=td.ndocumento AND
		doc.ndocumento=id.ndocumento AND
		case 
                        when doc.fecha::date + interval '1 day'*id.vencimiento < CURRENT_DATE then false
                        when doc.estado = false then false
                        when id.procesado = true then false
                        else true end and

		td.id=g.id) AS foo 
LEFT OUTER JOIN 
	establecimiento e 
ON 
	foo.id=e.id;