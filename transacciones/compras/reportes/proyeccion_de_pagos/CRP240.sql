drop table if exists aux_parametros_reporte;
create temp table aux_parametros_reporte as
select
	--''::date as fechai,
	'?'::date as fechaf,
	'?'::varchar as id_char;


drop table if exists aux_anticipos_dev_en_compras;
create temp table aux_anticipos_dev_en_compras as
SELECT	
	D.fecha,
	c.dcredito,
 	c.idtercero,
	d.codigo_tipo||'-'||d.numero::BIGINT||case when i.ex_documento is not null and trim(i.ex_documento,'') != '' then ' / '||i.ex_documento else '' end AS numero_dc,
	d2.codigo_tipo||'-'||d2.numero::BIGINT||case when i2.ex_documento is not null and trim(i2.ex_documento,'') != '' then ' / '||i2.ex_documento else '' end AS numero_ea,
	c.nfactura,
	SUM(c.neto_factura) AS vfactura,
	SUM(c.total_factura) AS tfactura,
	ac.char_cta,
	ac.id_cta,
	d.ndocumento
FROM
	cartera c,
	documentos d,
	documentos d2,
	info_documento i,
	info_documento i2,
	cuentas ac,
	aux_parametros_reporte a
WHERE
	ac.char_cta ilike '1330%' and --anticipos y avances
	i.rf_documento = d2.ndocumento and
	i.rf_documento = i2.ndocumento and
	d.ndocumento=c.nfactura and
	d.ndocumento = i.ndocumento and
	ac.id_cta=c.id_cta AND
	d.estado='true' AND
	c.total_factura>0 and
	--d.fecha::date between a.fechai and a.fechaf and
	d.fecha::date <= a.fechaf and
	case when a.id_char is null or trim(a.id_char) = '' then true else c.idtercero = (select id from general where id_char = a.id_char) end 
GROUP BY
	d.fecha,
	c.nfactura,
	c.dcredito,	
	d.codigo_tipo,
	d.numero,
	d2.codigo_tipo,
	d2.numero,
	i2.ex_documento,
 	c.idtercero,
	c.nfactura,
	c.dcredito,
	ac.char_cta,
	ac.id_cta,
	i.ex_documento,
	d.ndocumento;

drop table if exists aux_saldo_anticipos_dev_en_compras;
create temp table aux_saldo_anticipos_dev_en_compras as
select
	g.id_char,
	trim(coalesce(g.nombre1,'')||' '||coalesce(g.nombre2,'')||' '||coalesce(g.apellido1,'')||' '||coalesce(g.apellido2,'')||' '||coalesce(g.razon_social,'')) as nombre_tercero,
	fecha,
	vencimiento,
	numero,
	saldo,
	ex_documento
FROM
	(select
		foo.idtercero,
		CAST(fecha AS date) AS fecha,
		CAST(textcat(text(foo.dcredito), text(' dias')) AS text) AS dcredito,
		CAST(fecha + CAST(textcat(text(dcredito), text(' days')) as interval) AS date) AS vencimiento,
		foo.numero,
		saldo,
		null::text as ex_documento,
		foo.ndocumento,
		vfactura,
		char_cta,
		id_cta
	FROM
		(select
			c.idtercero,
			c.fecha,
			c.dcredito,
			c.numero_dc||'-'||c.numero_ea as numero,
			c.nfactura,
			c.vfactura,
			c.tfactura,
			c.tfactura+COALESCE(co.vcomprobante,0) AS saldo,
			c.char_cta,
			c.id_cta,
			c.ndocumento
		FROM
			aux_anticipos_dev_en_compras AS c
		LEFT OUTER JOIN
			(SELECT
				c.nfactura,
			 	c.idtercero,
				SUM(COALESCE(c.cargo_comprobante,0))-(SUM(COALESCE(c.abono_comprobante,0))+SUM(COALESCE(c.dcto_comprobante,0))) AS vcomprobante
			FROM
				cartera c,
				cuentas cu,
				documentos d,
				aux_parametros_reporte a
			where
				d.fecha::date <= a.fechaf and
				c.ncomprobante=d.ndocumento and
				c.id_cta = cu.id_cta and
				cu.char_cta like '1330%' and
				d.estado='true'
			GROUP BY
				c.nfactura,
				c.idtercero) AS co
		ON
			co.nfactura=c.nfactura  AND
			co.idtercero = c.idtercero) AS foo
	LEFT OUTER JOIN
		info_documento if
	ON
		if.ndocumento=foo.ndocumento) as foo
inner join
	general g
on
	foo.idtercero = g.id
WHERE
	foo.saldo!=0;



drop table if exists aux_facturas_pendientes;
create temp table aux_facturas_pendientes as
SELECT	
	D.fecha,
	c.dcredito,
 	c.idtercero,
	d.codigo_tipo||'-'||d.numero::BIGINT||case when i.ex_documento is not null and trim(i.ex_documento,'') != '' then '/'||i.ex_documento else '' end AS numero,
	c.nfactura,
	SUM(c.neto_factura) AS vfactura,
	SUM(c.total_factura) AS tfactura,
	ac.char_cta,
	ac.id_cta,
	d.ndocumento
FROM
	cartera c,
	documentos d,
	info_documento i,
	cuentas ac,
	aux_parametros_reporte a
WHERE
	ac.char_cta ilike '2205%' AND
	d.ndocumento=c.nfactura and
	d.ndocumento = i.ndocumento and
	ac.id_cta=c.id_cta AND
	d.estado='true' AND
	c.total_factura>0 and
	--d.fecha::date between a.fechai and a.fechaf and
	d.fecha::date <= a.fechaf and
	case when a.id_char is null or trim(a.id_char) = '' then true else c.idtercero = (select id from general where id_char = a.id_char) end 
GROUP BY
	d.fecha,
	c.nfactura,
	c.dcredito,	
	d.codigo_tipo,
	d.numero,
 	c.idtercero,
	c.nfactura,
	c.dcredito,
	ac.char_cta,
	ac.id_cta,
	i.ex_documento,
	d.ndocumento;

drop table if exists aux_documentos_con_saldo; -- incluye anticipos por cruzar y facturas EA
create temp table aux_documentos_con_saldo as
select
	g.id_char,
	trim(coalesce(g.nombre1,'')||' '||coalesce(g.nombre2,'')||' '||coalesce(g.apellido1,'')||' '||coalesce(g.apellido2,'')||' '||coalesce(g.razon_social,'')) as nombre_tercero,
	fecha,
	vencimiento,
	numero,
	saldo,
	ex_documento
FROM
	(select
		foo.idtercero,
		CAST(fecha AS date) AS fecha,
		CAST(textcat(text(foo.dcredito), text(' dias')) AS text) AS dcredito,
		CAST(fecha + CAST(textcat(text(dcredito), text(' days')) as interval) AS date) AS vencimiento,
		foo.numero,
		saldo,
		' '||if.ex_documento as ex_documento,
		foo.ndocumento,
		vfactura,
		char_cta,
		id_cta
	FROM
		(select
			c.idtercero,
			c.fecha,
			c.dcredito,
			c.numero,
			c.nfactura,
			c.vfactura,
			c.tfactura,
			c.tfactura+COALESCE(co.vcomprobante,0) AS saldo,
			c.char_cta,
			c.id_cta,
			c.ndocumento
		FROM
			aux_facturas_pendientes AS c
		LEFT OUTER JOIN
			(SELECT
				c.nfactura,
			 	c.idtercero,
				SUM(COALESCE(c.cargo_comprobante,0))-(SUM(COALESCE(c.abono_comprobante,0))+SUM(COALESCE(c.dcto_comprobante,0))) AS vcomprobante
			FROM
				cartera c,
				cuentas cu,
				documentos d,
				aux_parametros_reporte a
			where
				d.fecha::date <= a.fechaf and
				c.ncomprobante=d.ndocumento and
				c.id_cta = cu.id_cta and
				cu.char_cta like '2205%' and
				d.estado='true'
			GROUP BY
				c.nfactura,
				c.idtercero) AS co
		ON
			co.nfactura=c.nfactura  AND
			co.idtercero = c.idtercero) AS foo
	LEFT OUTER JOIN
		info_documento if
	ON
		if.ndocumento=foo.ndocumento) as foo
inner join
	general g
on
	foo.idtercero = g.id
WHERE
	foo.saldo!=0
union all
select
	a.id_char,
	a.nombre_tercero,
	a.fecha,
	a.vencimiento,
	a.numero,
	a.saldo,
	a.ex_documento
from
	aux_saldo_anticipos_dev_en_compras a;

SELECT
	a.id_char,
	a.nombre_tercero,
	a.fecha,
	a.vencimiento,
	a.numero,
	a.saldo
FROM
	aux_documentos_con_saldo a
ORDER by
		nombre_tercero,
		ex_documento nulls first,
		numero;

