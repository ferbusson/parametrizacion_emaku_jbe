SELECT 
	--0
	c.nombre, 
	--1
	p.terceros, 
	--2
	p.inventarios,
	--3
	p.centro,
	--4
	c.id_cta,
	--5
	0.0 AS cero,
	--6
	' ' AS vacio,
	--7
	current_timestamp,
	--8
	p.scentro,
	--9
	p.edocumento,
	--10
	p.vinculada,
	--11
	NEXTVAL('orden_seq'),
	--12
	CASE WHEN p.terceros THEN tercero ELSE '' END,
	--13
	p.naturaleza,
	--14
	p.retencion,
	--15
	p.base
FROM 
	(SELECT
		'?'::character(10) AS char_cta,
		'?'::character(25) AS tercero) AS foo,
	cuentas c,
	perfil_cta p 
WHERE 
	c.id_cta=p.id_cta AND 	
	c.char_cta=foo.char_cta;