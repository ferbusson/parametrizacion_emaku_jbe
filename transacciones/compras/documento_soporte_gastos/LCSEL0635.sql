SELECT 
	e.id_tercero_banco,
	'51159525' AS cuenta_gravamen,
	c.id_cta,
	CASE WHEN pc.edocumento THEN 'TRUE' ELSE 'FALSE' END AS edocumento,
	CASE WHEN pc.centro THEN 1 ELSE 0 END AS cc,
	CASE WHEN pc.scentro THEN 1 ELSE 0 END AS scc,
	NEXTVAL('tagdata') AS tag
FROM 
	enlace_bancos e,
	cuentas c,
	perfil_cta pc
WHERE 
	c.id_cta = e.id_cta AND
	c.id_cta = pc.id_cta AND
	c.char_cta = '?';