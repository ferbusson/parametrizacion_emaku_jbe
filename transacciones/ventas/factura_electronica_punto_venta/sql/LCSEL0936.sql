-- ? ?
DROP TABLE IF EXISTS ids;
CREATE TEMP TABLE ids AS
SELECT
	CAST('?' AS varchar(50)) AS id;
	
SELECT 
	TRIM(coalesce(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||coalesce(g.apellido1,'')||' '||coalesce(g.apellido2,'')||' '||coalesce(g.razon_social,'')) as nombre,
	e.descripcion,
	g.id_char,
	g.id,
	pt.id_regimen,
	r.descripcion||chr(10)||c.nombre AS regimen,
	pt.id_catalogo,
	c.nombre AS catalogo,
	'-1'::INTEGER as ndocumento
FROM 
	ids,
	perfiles p,
	perfil_tercero pt,
	regimenes r,
	catalogo_pventa c,
	general g
LEFT OUTER JOIN
	tpuntos tp
ON
	g.id=tp.id
LEFT OUTER JOIN
	establecimiento e
ON
	g.id=e.id			
WHERE 
	(TRIM(g.nombre1||' '||g.nombre2||' '||g.apellido1||' '||g.apellido2||' '||g.razon_social) ILIKE '%'||ids.id||'%' OR
	g.id_char = ids.id) AND
	g.id=p.id AND
	pt.estado AND
	p.tipo='002' AND 
	pt.id=g.id AND 
	pt.id_regimen=r.id_regimen AND 
	c.id_catalogo=pt.id_catalogo;