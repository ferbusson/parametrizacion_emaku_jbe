select
	d.codigo_tipo||'-'||d.numero::bigint as factura,
	d.fecha::date as fecha,
	g.id_char,
  	TRIM(COALESCE(g.apellido1,'')||' '||
  	COALESCE(g.apellido2,'')||' '||
  	COALESCE(g.nombre1,'')||' '||
  	COALESCE(g.nombre2,'')||' '||
  	COALESCE(g.razon_social,'')) as nombre_tercero,
  	coalesce(pt.puntos_generados,0) as puntos_generados,
  	coalesce(pt.puntos_redimidos,0) as puntos_redimidos,
  	pt.saldo
from
	puntos_tercero pt
inner join
	documentos d
on
	pt.ndocumento = d.ndocumento
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
order by
	TRIM(COALESCE(g.apellido1,'')||' '||
  	COALESCE(g.apellido2,'')||' '||
  	COALESCE(g.nombre1,'')||' '||
  	COALESCE(g.nombre2,'')||' '||
  	COALESCE(g.razon_social,'')),
	d.fecha;