SELECT 
	TRIM(coalesce(g.nombre1,'')||' '||coalesce(g.nombre2,'')||' '||coalesce(g.apellido1,'')||' '||coalesce(g.apellido2,'')||' '||coalesce(g.razon_social,'')) as nombre,
	NULL AS establecimiento,
	g.id_char,
	g.id,
	pt.id_regimen,
	r.descripcion AS regimen,
	pt.id_catalogo,
	c.nombre AS catalogo,
	-1::smallint as ndocumento
FROM 
	general g,
	perfiles p,
	perfil_tercero pt,
	regimenes r,
	catalogo_pventa c 
WHERE 
	g.id_char = '222222222222' AND
	g.id=p.id AND 
	p.tipo='002' AND 
	pt.id=g.id AND 
	pt.id_regimen=r.id_regimen AND 
	c.id_catalogo=pt.id_catalogo;