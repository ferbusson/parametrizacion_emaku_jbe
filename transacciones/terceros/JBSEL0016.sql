SELECT --?
	tiene_precio_base
FROM 
	perfil_tercero p 
WHERE 
	p.id=(SELECT id FROM general WHERE id_char='?');