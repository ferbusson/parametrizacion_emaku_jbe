SELECT --?
	--descripcion,
	numero,
	dnombre||' '||id_dep as departamento,
	mnombre||' '||municipio as municipio,
	tnombre||' '||clase as tipo,
	foo.id_telefono,
	count(tercero_def.id_telefono)
FROM 
	(SELECT 
		id_telefono,
		descripcion,
		numero,
		pais.nombre AS pnombre,
		pais.id_pais,
		departamentos.nombre AS dnombre,
		departamentos.id_dep,
		municipios.nombre AS mnombre,
		municipios.municipio,
		tipos_telefono.nombre AS tnombre,
		tipos_telefono.clase 
	FROM 
		telefonos,
		tipos_telefono,
		general,
		pais,
		departamentos,
		municipios 
	WHERE 
		general.id=telefonos.id AND 
		telefonos.municipio=municipios.municipio AND 
		telefonos.id_dep=municipios.id_dep AND 
		telefonos.id_pais=municipios.id_pais AND 
		telefonos.id_dep = departamentos.id_dep AND 
		telefonos.id_pais=departamentos.id_pais AND 
		telefonos.id_pais = pais.id_pais AND 
		telefonos.clase=tipos_telefono.clase AND 
		general.id_char='?') AS foo 
LEFT OUTER JOIN 
	tercero_def 
ON 
	foo.id_telefono=tercero_def.id_telefono 
GROUP BY 
	foo.id_telefono,
	descripcion,
	numero,
	pnombre,
	id_pais,
	dnombre,
	id_dep,
	mnombre,
	municipio,
	tnombre,
	clase
ORDER BY
	foo.id_telefono DESC;