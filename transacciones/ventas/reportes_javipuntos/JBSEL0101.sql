select
	g.id_char,
  	TRIM(COALESCE(g.apellido1,'')||' '||
  	COALESCE(g.apellido2,'')||' '||
  	COALESCE(g.nombre1,'')||' '||
  	COALESCE(g.nombre2,'')||' '||
  	COALESCE(g.razon_social,'')) as nombre_tercero,
  	sum(coalesce(pt.puntos_generados,0)) as puntos_generados,
  	sum(coalesce(pt.puntos_redimidos,0)) as puntos_redimidos,
  	sum(coalesce(pt.puntos_generados,0)) - sum(coalesce(pt.puntos_redimidos,0)) as saldo
from
	puntos_tercero pt
inner join
	general g
on
	pt.id_tercero= g.id
where
	g.id_char||'-'||TRIM(COALESCE(g.apellido1,'')||' '||
  	COALESCE(g.apellido2,'')||' '||
  	COALESCE(g.nombre1,'')||' '||
  	COALESCE(g.nombre2,'')||' '||
  	COALESCE(g.razon_social,'')) ilike '%?%'
group by
	g.id_char,
  	TRIM(COALESCE(g.apellido1,'')||' '||
  	COALESCE(g.apellido2,'')||' '||
  	COALESCE(g.nombre1,'')||' '||
  	COALESCE(g.nombre2,'')||' '||
  	COALESCE(g.razon_social,''))
order by
	TRIM(COALESCE(g.apellido1,'')||' '||
  	COALESCE(g.apellido2,'')||' '||
  	COALESCE(g.nombre1,'')||' '||
  	COALESCE(g.nombre2,'')||' '||
  	COALESCE(g.razon_social,''));