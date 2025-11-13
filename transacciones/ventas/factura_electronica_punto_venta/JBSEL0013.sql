SELECT 
	false,
	id_char AS nit,
	nombre1 || nombre2 || ' '|| apellido1 || apellido2 AS nombre,
	0 AS valor,
	0 AS contador,
	g.id AS id_empleado,
	'52051801',
	'23352001',
        sigla
FROM 
	general g,
	info_empleado i
WHERE
	g.id = i.id AND
	(i.id_cargo_empleado = 'VEN')


