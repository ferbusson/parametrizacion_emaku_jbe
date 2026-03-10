SELECT 
	c.char_cta,
	c.nombre,
	pc.base,
	pc.porcentaje,
	0,
	cr.id_cta 
FROM 
	perfil_tercero p,
	cuentas_regimen cr,
	cuentas c,
	perfil_cta pc 
WHERE 
	cr.id_regimen=p.id_regimen AND 
	cr.id_cta=c.id_cta AND 
	pc.id_cta=c.id_cta AND 
	p.id='?' AND 
	cr.codigo_tipo='?' AND 
        c.char_cta like '24081520%';