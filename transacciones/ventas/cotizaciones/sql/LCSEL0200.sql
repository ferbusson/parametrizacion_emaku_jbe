SELECT
	c.char_cta,
	c.nombre,
	pc.base,
	pc.porcentaje,
	0,
	rd.id_cta,
        0,
        '06'
FROM 
	perfil_tercero p,
	regimen_documento_sucursal rd,
	documentos_sucursales ds,
	cuentas c,
	perfil_cta pc 
WHERE 
	rd.id_regimen=p.id_regimen AND 
	rd.id_cta=c.id_cta AND 
	pc.id_cta=c.id_cta AND 
	p.id='?' AND 
	ds.id_documento = rd.id_documento AND
	ds.codigo_tipo='?' AND 
	c.char_cta like '1355%'