DROP TABLE IF EXISTS args_arqueo_fac;
CREATE TEMP TABLE args_arqueo_fac AS
select
	da.narqueo,
	da.ndocumento
from
	datos_arqueo da
where
	da.narqueo = '?';


DROP TABLE IF EXISTS codigo_tipo_fac;
CREATE TEMP TABLE codigo_tipo_fac AS
SELECT
	dsf.codigo_tipo
FROM
	documentos_standar s,
	documentos_sucursales ds,
	(select a.narqueo as ndocumento from args_arqueo_fac a limit 1) as a,
	documentos_standar sf,
	documentos_sucursales dsf,
	documentos d
WHERE
	ds.id_administracion_sucursales=dsf.id_administracion_sucursales AND
	sf.id_documento=dsf.id_documento AND
	sf.nombre='ANTICIPOS FACTURACION' AND
	s.id_documento=ds.id_documento AND
	ds.codigo_tipo=d.codigo_tipo AND
	d.ndocumento=a.ndocumento ;

DROP TABLE IF EXISTS doc_caja;
CREATE TEMP TABLE doc_caja AS
SELECT
	l.id_cta,
	l.ndocumento,
	l.fecha,
	d.codigo_tipo||'-'||d.numero::bigint AS numero,
	l.debe
FROM
	documentos d,
	libro_auxiliar l,
	codigo_tipo_fac cf,
	args_arqueo_fac af
where
	l.ndocumento=af.ndocumento and
	l.debe != 0 and
	d.ndocumento=af.ndocumento and
	d.estado AND
	d.codigo_tipo=cf.codigo_tipo;
	
SELECT
	dc.ndocumento,
	dc.fecha,
	dc.numero,
	case when c.char_cta ~ '110535.' then dc.debe else 0 end as efectivo,
	case when c.char_cta !~ '110535.' then dc.debe else 0 end as otros_medios,
	dc.debe as total,
	c.char_cta
FROM
	doc_caja dc,
	cuentas c
WHERE
	dc.id_cta=c.id_cta
ORDER BY
	numero;