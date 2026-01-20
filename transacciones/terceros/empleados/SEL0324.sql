SELECT 
	id_char,
	id_char||' '||TRIM(COALESCE(nombre1,'')||' '||COALESCE(nombre2,'')||' '||COALESCE(apellido1,'')||' '||COALESCE(apellido2,'')||' '||COALESCE(razon_social,'')) as nombre
FROM 
	general g,
	perfiles p 
WHERE 
	g.id=p.id AND 
	p.tipo='002' AND 
	(g.id_char like '%?%' OR 
	TRIM(COALESCE(nombre1,'')||' '||COALESCE(nombre2,'')||' '||COALESCE(apellido1,'')||' '||COALESCE(apellido2,'')||' '||COALESCE(razon_social,'')) ilike '%?%')
ORDER BY
	TRIM(COALESCE(nombre1,'')||' '||COALESCE(nombre2,'')||' '||COALESCE(apellido1,'')||' '||COALESCE(apellido2,'')||' '||COALESCE(razon_social,''));