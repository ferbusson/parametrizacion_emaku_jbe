SELECT 
	c.char_cta,
	c.nombre,
	pc.base,
	ta.tarifa,
	0,
	c.id_cta,
	0 AS valor_base,
	'07' AS id_retenciones_taxscheme,
	NEXTVAL('tagdata') AS tag
FROM 
	cuentas c,
	perfil_cta pc,
	tarifas_actividad ta 
WHERE 
	pc.id_cta=c.id_cta AND 
	ta.id_cta=c.id_cta AND 
	c.char_cta = '?';