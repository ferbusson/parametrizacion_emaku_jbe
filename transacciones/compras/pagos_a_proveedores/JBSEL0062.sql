--JBSEL0062
drop table if exists aux_facturas_pendientes;
create temp table aux_facturas_pendientes as
SELECT
	D.fecha,
	c.dcredito,
 	c.idtercero,
	d.codigo_tipo||'-'||d.numero::BIGINT||case when i.ex_documento is not null and trim(i.ex_documento,'') != '' then ' / '||i.ex_documento else '' end AS numero,
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
	cuentas ac
WHERE
 	c.idtercero='?' AND
	ac.char_cta ilike '2%' AND
	d.ndocumento=c.nfactura and
	d.ndocumento = i.ndocumento and
	ac.id_cta=c.id_cta AND
	d.estado='true' AND
	c.total_factura>0
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

select
	false as seleccion,
	fecha,
	dcredito,
	vencimiento,
	numero,
	saldo,
	0 as abono,
	0 as pdescuento,
	0 as valor_descuento,
	0 as total_pagar,
	0 as saldo_factura,
	ex_documento as fac_proveedor,
	ndocumento,
	vfactura,
	0 as valor_pago,
	char_cta,
	id_cta,
	round((saldo/1.19)::numeric,2) as valor_base,
	0 as contador_factura
FROM
	(SELECT
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
			aux_facturas_pendientes AS c
		LEFT OUTER JOIN
			(SELECT
				c.nfactura,
			 	c.idtercero,
				SUM(COALESCE(c.cargo_comprobante,0))-(SUM(COALESCE(c.abono_comprobante,0))+SUM(COALESCE(c.dcto_comprobante,0))) AS vcomprobante
			FROM
				cartera c,
				documentos d
			WHERE
				c.ncomprobante=d.ndocumento AND
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
		if.ndocumento=foo.ndocumento 
	ORDER BY
		fecha,numero) as foo
WHERE
	foo.saldo!=0;

