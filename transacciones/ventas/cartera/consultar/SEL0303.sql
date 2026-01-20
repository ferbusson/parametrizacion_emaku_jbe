DROP TABLE IF EXISTS aux_cartera;
CREATE TEMP TABLE aux_cartera AS
SELECT
	ndocumento
FROM
	documentos
WHERE
	codigo_tipo = '?' AND
	numero = LPAD('?',10,'0');

SELECT 
	foo.fecha,
	CAST(textcat(text(foo.dcredito), text(' dias')) AS text) AS dcredito,
	foo.fecha + CAST(textcat(text(foo.dcredito), text(' days')) as interval) AS vencimiento,
	foo.numero,
	foo.debe,
	c.abono_comprobante,
	c.pdcto_comprobante,
	c.dcto_comprobante,
	foo.debe-c.dcto_comprobante - c.abono_comprobante AS saldo,
	0,
	foo.debe AS valor_factura,
	c.abono_comprobante+c.dcto_comprobante AS abono,
	c.dcto_comprobante as descuentoimp,
	foo.debe-c.dcto_comprobante - c.abono_comprobante AS saldoimp
FROM
	(SELECT
		MAX(d.fecha) AS fecha,
		c.nfactura,
		SUM(COALESCE(c2.dcredito,0)) AS dcredito,
		doc.numero,
		SUM(c.saldo_anterior) AS debe
	FROM
		(SELECT
			d.ndocumento,
			COALESCE(rf.prefijo,d.codigo_tipo)||'-'||d.numero::BIGINT||' ** '||i.ex_documento AS numero
		 FROM
		 	administracion_sucursales a,
		 	documentos_sucursales ds,
		 	info_documento i,
		 	documentos d
		LEFT OUTER JOIN
			resolucion_documento rd
		ON
			d.ndocumento = rd.ndocumento
		LEFT OUTER JOIN
			resolucion_facturacion rf
		ON
			rd.id_resolucion_facturacion = rf.id_resolucion_facturacion
		where
			i.ndocumento = d.ndocumento and
			a.id_administracion_sucursales = ds.id_administracion_sucursales AND
			ds.codigo_tipo = d.codigo_tipo AND
			d.estado) AS doc,
		documentos d,
		cartera c, -- Registro en cartera del CI ncomprobante
		cartera c2, -- Registro en cartera de la factura nfactura
		aux_cartera a
	WHERE 	
		a.ndocumento = c.ncomprobante AND
		d.ndocumento=c.nfactura AND
		doc.ndocumento=c.nfactura AND
		c.nfactura = c2.nfactura AND
		c2.ncomprobante IS NULL
	GROUP BY 
		c.nfactura,
		doc.numero) AS foo,
	
	cartera c,
	aux_cartera a
WHERE
	c.ncomprobante = a.ndocumento AND
	c.nfactura=foo.nfactura
union all
SELECT 
	foo1.fecha,
	CAST(textcat(text(foo1.dcredito), text(' dias')) AS text) AS dcredito,
	foo1.fecha + CAST(textcat(text(foo1.dcredito), text(' days')) as interval) AS vencimiento,
	foo1.numero,
	foo1.debe,
	c.abono_comprobante,
	c.pdcto_comprobante,
	c.dcto_comprobante,
	foo1.debe-c.dcto_comprobante - c.abono_comprobante AS saldo,
	0,
	foo1.debe AS valor_factura,
	c.abono_comprobante+c.dcto_comprobante AS abono,
	c.dcto_comprobante as descuentoimp,
	foo1.debe-c.dcto_comprobante - c.abono_comprobante AS saldoimp
FROM
	(SELECT
		MAX(d.fecha) AS fecha,
		c.nfactura,
		SUM(COALESCE(c2.dcredito,0)) AS dcredito,
		doc.numero,
		SUM(c.saldo_anterior) AS debe
	FROM
		(SELECT
			d.ndocumento,
			COALESCE(rf.prefijo,d.codigo_tipo)||'-'||d.numero::BIGINT||' ** '||i.ex_documento AS numero
		 from
		 	info_documento i,
		 	documentos d
		LEFT OUTER JOIN
			resolucion_documento rd
		ON
			d.ndocumento = rd.ndocumento
		LEFT OUTER JOIN
			resolucion_facturacion rf
		ON
			rd.id_resolucion_facturacion = rf.id_resolucion_facturacion
		where
			d.codigo_tipo in ('FC','1B') and 
			d.estado and 
			i.ndocumento = d.ndocumento) AS doc,
		documentos d,
		cartera c, -- Registro en cartera del CI ncomprobante
		cartera c2, -- Registro en cartera de la factura nfactura
		aux_cartera a
	WHERE 	
		a.ndocumento = c.ncomprobante AND
		d.ndocumento=c.nfactura AND
		doc.ndocumento=c.nfactura AND
		c.nfactura = c2.nfactura AND
		c2.ncomprobante IS NULL
	GROUP BY 
		c.nfactura,
		doc.numero) AS foo1,
	
	cartera c,
	aux_cartera a
WHERE
	c.ncomprobante = a.ndocumento AND
	c.nfactura=foo1.nfactura
ORDER BY
	fecha;--,
--	foo.nfactura;