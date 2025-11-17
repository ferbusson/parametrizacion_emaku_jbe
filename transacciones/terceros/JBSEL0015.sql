SELECT --?
	es_pintor 
FROM 
	perfil_tercero p 
WHERE 
	p.id=(SELECT id FROM general WHERE id_char='?');