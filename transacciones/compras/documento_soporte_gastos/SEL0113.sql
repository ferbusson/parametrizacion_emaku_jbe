SELECT 
	comision,
	c.char_cta,
	id_tercero_banco,
	CASE WHEN pc.edocumento THEN 'TRUE' ELSE 'FALSE' END AS edocumento,
	CASE WHEN pc.centro THEN 1 ELSE 0 END AS cc,
	CASE WHEN pc.scentro THEN 1 ELSE 0 END AS scc,
	NEXTVAL('tagdata') AS tag
FROM 
	tcredito tc,
	cuentas c,
	perfil_cta pc
WHERE 
	tc.id_banco = c.id_cta AND
	c.id_cta = pc.id_cta AND
	id_tcredito='?';