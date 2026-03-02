SELECT
	nombre,
	c.id_cta,
	ROUND((RANDOM()*1000)::numeric,0) AS tag,
        'NULL',
        nombre,
        CASE WHEN pc.edocumento THEN 'TRUE' ELSE 'FALSE' END AS edocumento,
        CASE WHEN pc.centro THEN 1 ELSE 0 END AS cc,
        CASE WHEN pc.scentro THEN 1 ELSE 0 END AS sc
FROM
	cuentas c,
	perfil_cta pc,
	(SELECT
		'?'::character(10) AS char_cta) AS t
WHERE 
	c.id_cta=pc.id_cta AND
	c.tipo='FALSE' AND	
	c.activa='TRUE' AND
	c.char_cta=t.char_cta;