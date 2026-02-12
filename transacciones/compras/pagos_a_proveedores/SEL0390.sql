SELECT
        foo.fecha,
        CAST(textcat(text(foo.dcredito), text(' dias')) AS text) AS dcredito,
        foo.fecha + CAST(textcat(text(foo.dcredito), text(' days')) as interval) AS vencimiento,
        foo.numero,
        foo.debe+c.abono_comprobante+c.dcto_comprobante,
        c.abono_comprobante,
        c.pdcto_comprobante,
        c.pdcto2_comprobante,
        c.pdcto3_comprobante,
        c.dcto_comprobante,
        0,
	' '||foo.ex_documento,
        0,
        0,
	0,
        foo.nfactura,
        foo.total_factura
FROM
        (SELECT
                MAX(d.fecha) AS fecha,
                c.nfactura,
                SUM(c.dcredito) AS dcredito,
                doc.numero,
		i.ex_documento,
		SUM(c.total_factura) AS total_factura,
                SUM(c.total_factura-(c.abono_comprobante+c.dcto_comprobante)) AS debe
        FROM
                (SELECT
                        d.ndocumento,
                        d.codigo_tipo||d.numero AS numero
                 FROM
                        documentos d) AS doc,
                documentos d,
                cartera c,
		info_documento i
        WHERE
		c.nfactura=i.ndocumento AND
                d.ndocumento=COALESCE(c.ncomprobante,c.nfactura) AND
                doc.ndocumento=c.nfactura AND
                d.estado='true'
        GROUP BY
                c.nfactura,
                doc.numero,
		i.ex_documento) AS foo,
        documentos d,
        info_documento i,
        cartera c
WHERE
        i.ndocumento=d.ndocumento AND
        c.nfactura=foo.nfactura AND
        c.ncomprobante=i.rf_documento AND
        d.codigo_tipo='?'AND
        d.numero=LPAD('?',10,'0')
ORDER BY
        foo.nfactura,
        foo.fecha
