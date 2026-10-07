--JBSEL0120
drop table if exists aux_parametros_query;
create temp table aux_parametros_query as
select
	t.id as id_tercero,
	t.ndocumento
from
	tercero_def t
where
	t.ndocumento = '?'; --ndocumento

SELECT
	ndocumento,
	fecha||' No.'||numero||' $ '||saldo 
FROM
	(SELECT
		CAST(fecha AS date) AS fecha,
		CAST(textcat(text(foo.dcredito), text(' dias')) AS text) AS dcredito,
		CAST(fecha + CAST(textcat(text(dcredito), text(' days')) as interval) AS date) AS vencimiento,
		foo.numero,
		saldo,
		COALESCE(' '||if.ex_documento,'') as ex_documento,
		foo.ndocumento,
		vfactura,
		char_cta,
		id_cta
	FROM
		(SELECT
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
			(SELECT
				d.fecha,
				c.dcredito,
				d.codigo_tipo||d.numero AS numero,
				c.nfactura,
				c.idtercero,
				SUM(c.neto_factura) AS vfactura,
				SUM(c.total_factura) AS tfactura,
				ac.char_cta,
				ac.id_cta,
				d.ndocumento
			FROM
				cartera c,
				aux_parametros_query a,
				documentos d,
				cuentas ac
			WHERE
				--cast(c.idtercero as character(15))='aqui estaba la interrogacion' AND
				c.idtercero = a.id_tercero and
				ac.char_cta ilike '13%' AND
				d.ndocumento=c.nfactura AND
				ac.id_cta=c.id_cta AND
				d.estado='true' AND
				c.total_factura>0
			GROUP BY
				d.fecha,
				c.nfactura,
				c.dcredito,	
				d.codigo_tipo,
				d.numero,
				c.nfactura,
				c.idtercero,
				c.dcredito,
				ac.char_cta,
				ac.id_cta,
				d.ndocumento
			union
			SELECT
				D.fecha,
				c.dcredito,
				d.codigo_tipo||d.numero AS numero,
				c.nfactura,
				c.idtercero,
				SUM(c.neto_factura) AS vfactura,
				SUM(c.total_factura) AS tfactura,
				ac.char_cta,
				ac.id_cta,
				d.ndocumento
			from
				aux_parametros_query a,
				cartera c,
				documentos d,
				cuentas ac
			WHERE
				--cast(c.idtercero as character(15))='' AND
				c.nfactura = a.ndocumento and
				ac.char_cta ilike '13%' AND
				d.ndocumento=c.nfactura AND
				ac.id_cta=c.id_cta AND
				d.estado='true' AND
				c.total_factura>0
			GROUP BY
				d.fecha,
				c.nfactura,
				c.dcredito,	
				d.codigo_tipo,
				d.numero,
				c.nfactura,
				c.idtercero,
				c.dcredito,
				ac.char_cta,
				ac.id_cta,
				d.ndocumento) AS c
		LEFT OUTER JOIN
			(SELECT
				c.nfactura,
				c.id_cta,
				c.idtercero,
				SUM(COALESCE(c.cargo_comprobante,0))-(SUM(COALESCE(c.abono_comprobante,0))+SUM(COALESCE(c.dcto_comprobante,0))) AS vcomprobante
			FROM
				cartera c,
				documentos d
			WHERE
				c.ncomprobante=d.ndocumento and
				d.estado='true'
			GROUP BY
				c.nfactura,
				c.id_cta,
				c.idtercero) AS co
		ON
			co.nfactura=c.nfactura and
			co.idtercero = c.idtercero and
			co.id_cta = c.id_cta) AS foo
	LEFT OUTER JOIN
		info_documento if
	ON
		if.ndocumento=foo.ndocumento 
	ORDER BY
		fecha) as foo
WHERE
	foo.saldo!=0
ORDER BY
	fecha,
	numero;