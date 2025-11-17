SELECT 	--?
	--descripcion,
	direccion,
	id_email,
	0 
FROM 
	emails,
	general 
WHERE 
	general.id=emails.id AND 
	general.id_char='?';