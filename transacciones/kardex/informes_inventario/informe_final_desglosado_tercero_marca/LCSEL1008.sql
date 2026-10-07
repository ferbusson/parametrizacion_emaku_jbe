--LCSEL1008
select
	foo.id,
	foo.nombre
from
	(SELECT 
		g.id,
		TRIM(COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2)||' '||COALESCE(g.apellido1)||' '||COALESCE(g.apellido2)||' '||COALESCE(g.razon_social)) as nombre 
	FROM 
		general g,
		perfiles p
where
		g.id = p.id and
		p.tipo = '006' and
		g.id IN (138,140,245,243,241)
	/*union
	select
		-1,
		'TODAS' as nombre*/
		) as foo
ORDER by
	case when foo.id = 140 then 1000 end desc;