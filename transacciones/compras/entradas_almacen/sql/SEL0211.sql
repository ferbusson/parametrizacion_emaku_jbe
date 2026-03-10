SELECT 
	c.char_cta,
	c.nombre,
	ta.base,
	ta.tarifa,
	0,
	cr.id_cta 
FROM 
	perfil_tercero p,
	cuentas_regimen cr,
	cuentas c,
	perfil_cta pc,
	tarifas_actividad ta 
WHERE 
	cr.id_regimen=p.id_regimen AND 
	cr.id_cta=c.id_cta AND 
	pc.id_cta=c.id_cta AND 
	ta.id_cta=c.id_cta AND 
	ta.id_actividad_economica=p.id_actividad_economica AND 
	p.id='?' AND 
	cr.codigo_tipo='?';