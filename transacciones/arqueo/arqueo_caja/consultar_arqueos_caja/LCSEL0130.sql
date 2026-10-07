DROP TABLE IF EXISTS args_arqueo_fac;
CREATE TEMP TABLE args_arqueo_fac AS
SELECT
	'?'::BIGINT AS ndocumento;

DROP TABLE IF EXISTS codigo_tipo_fac;
CREATE TEMP TABLE codigo_tipo_fac AS
SELECT
	dsf.codigo_tipo
FROM
	documentos_standar s,
	documentos_sucursales ds,
	args_arqueo_fac a,
	documentos_standar sf,
	documentos_sucursales dsf,
	documentos d
WHERE
	ds.id_administracion_sucursales=dsf.id_administracion_sucursales AND
	sf.id_documento=dsf.id_documento AND
	sf.nombre='COMPROBANTES INGRESO' AND
	s.id_documento=ds.id_documento AND
	ds.codigo_tipo=d.codigo_tipo AND
	d.ndocumento=a.ndocumento ;


DROP TABLE IF EXISTS tmp_docs;
CREATE TEMP TABLE tmp_docs AS
SELECT
	d.*
FROM
	documentos d,
	documentos a,
	datos_arqueo da,
	codigo_tipo_fac cf,
	args_arqueo_fac af
WHERE
	d.estado AND
	d.codigo_tipo=cf.codigo_tipo AND 
	d.ndocumento=da.ndocumento AND
	da.narqueo=a.ndocumento AND
	a.ndocumento=af.ndocumento;

DROP TABLE IF EXISTS aq_datos;
CREATE TEMP TABLE aq_datos AS
SELECT
	l.id_cta,
	l.ndocumento,
	a.fecha,
	a.codigo_tipo||a.numero AS numero,
	l.debe,
	l.haber	
FROM
	libro_auxiliar l,
	tmp_docs a
WHERE
	a.ndocumento=l.ndocumento;

DROP TABLE IF EXISTS doc_caja;
CREATE TEMP TABLE doc_caja AS
SELECT
	dc.ndocumento,
	dc.fecha,
	dc.numero,
	SUM(dc.debe)-sum(dc.haber) AS debe, -- en JBE el id = 830 sistecredito registra abonos en el credito, por eso resto aqui el haber, de esta forma el arqueo es consistente - politicas propias
	c.char_cta
FROM
	aq_datos dc,
	cuentas c
WHERE
	dc.id_cta=c.id_cta AND
	c.char_cta ~ '110505.'
GROUP BY
	dc.ndocumento,
	dc.fecha,
	dc.numero,
	c.char_cta;
	

DROP TABLE IF EXISTS doc_otros;
CREATE TEMP TABLE doc_otros AS
SELECT
	dc.ndocumento,
	dc.fecha,
	dc.numero,
	SUM(dc.debe) AS debe
FROM
	aq_datos dc,
	cuentas c
WHERE
	dc.id_cta=c.id_cta AND
	dc.debe!=0 AND
	(c.char_cta like '1110%' or
	c.char_cta like '112005%' or
	c.char_cta like '2805%' or
	c.char_cta like '2380%' or
	c.char_cta like '11052%' OR
	c.char_cta ~ '112005.') -- transferencias, en el sistema se reciben como tarjeta
GROUP BY
	dc.fecha,
	dc.numero,
	dc.ndocumento;


DROP TABLE IF EXISTS docs_ok;
CREATE TEMP TABLE docs_ok AS
SELECT
	COALESCE(dc.ndocumento,dt.ndocumento) as ndocumento,
	COALESCE(dc.fecha,dt.fecha) as fecha,
	COALESCE(dc.numero,dt.numero) as numero,
	COALESCE(dc.debe,0) as caja,
	COALESCE(dt.debe, 0) as otros
FROM
	doc_caja dc
FULL OUTER JOIN
	doc_otros dt
ON
	dc.ndocumento=dt.ndocumento;

SELECT
	ndocumento,
	fecha,
	numero,
	caja,
	otros,
	caja+otros as total
FROM
	docs_ok
ORDER BY
	fecha;