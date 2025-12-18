SELECT 
	id_char,
	id_char||' '||TRIM(COALESCE(nombre1,'')||' '||COALESCE(nombre2,'')||' '||COALESCE(apellido1,'')||' '||COALESCE(apellido2,'')||' '||COALESCE(razon_social,'')) as nombre
FROM 
	general g,
	perfil_tercero pt
WHERE 
	g.id=pt.id AND 
	pt.es_pintor and -- si es true entra en el programa de javipuntos
	(g.id_char like '%?%' OR 
	TRIM(COALESCE(nombre1,'')||' '||COALESCE(nombre2,'')||' '||COALESCE(apellido1,'')||' '||COALESCE(apellido2,'')||' '||COALESCE(razon_social,'')) ilike '%?%')
ORDER BY
	TRIM(COALESCE(nombre1,'')||' '||COALESCE(nombre2,'')||' '||COALESCE(apellido1,'')||' '||COALESCE(apellido2,'')||' '||COALESCE(razon_social,''));