drop table if exists aux_parametros_query;
create temp table aux_parametros_query as
select
	'?'::text as id;

SELECT
	CAST(fecha AS date) AS fecha,
	CAST(textcat(text(dcredito), text(' dias')) AS text) AS dcredito,
	CAST(fecha + CAST(textcat(text(dcredito), text(' days')) as interval) AS date) AS vencimiento,
	numero,
	saldo,
	0,
	0,
	0,
	0,
	ndocumento,
	vfactura,
	0,
	char_cta,
	id_cta
FROM
(SELECT
	c.fecha,
	c.numero,
	c.idtercero,
	c.nfactura,
	c.dcredito,
	c.vfactura,
	c.tfactura,
	c.tfactura+COALESCE(co.cargos,0)-COALESCE(co.vcomprobante,0) AS saldo,
	c.char_cta,
	c.id_cta,
	c.ndocumento
FROM
        (SELECT
			d.fecha,
			COALESCE(rf.prefijo,d.codigo_tipo)||'-'||d.numero::BIGINT||'-'||coalesce(id.ex_documento,'-') AS numero,
			c.idtercero,
	        c.nfactura,
	        c.dcredito,
	        SUM(c.neto_factura) AS vfactura,
	        SUM(c.total_factura) AS tfactura,
			ac.char_cta,
			ac.id_cta,
			d.ndocumento
        FROM
			cartera c,
			cuentas ac,
			administracion_sucursales a,
			documentos_sucursales ds,
			info_documento id,
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
			d.codigo_tipo = ds.codigo_tipo AND
			ds.id_administracion_sucursales = a.id_administracion_sucursales AND
			ac.id_cta=c.id_cta and
			ac.char_cta not in ('28050502') and -- se excluyen los separados Oct 7 2024
			d.ndocumento=c.nfactura AND
			d.ndocumento=id.ndocumento AND
			c.idtercero= (select id::bigint from aux_parametros_query) AND
			d.estado='true' AND
			c.movimiento=true AND
			c.total_factura>0
	    GROUP BY
			d.fecha,
			COALESCE(rf.prefijo,d.codigo_tipo)||'-'||d.numero::BIGINT,
			id.ex_documento,
			d.ndocumento,
			c.idtercero,
            c.nfactura,
            c.dcredito,
			ac.id_cta,
			ac.char_cta) AS c
LEFT OUTER JOIN
        (SELECT
            c.nfactura,
            SUM(c.abono_comprobante)+SUM(c.dcto_comprobante) AS vcomprobante,
			SUM(c.cargo_comprobante) AS cargos
        FROM
            cartera c,
            documentos d
        WHERE
            c.ncomprobante=d.ndocumento AND
            d.estado='true'
        GROUP BY
            c.nfactura) AS co
ON
        co.nfactura=c.nfactura) AS foo
WHERE
	foo.saldo>0 
union all
SELECT
	CAST(fecha AS date) AS fecha,
	CAST(textcat(text(dcredito), text(' dias')) AS text) AS dcredito,
	CAST(fecha + CAST(textcat(text(dcredito), text(' days')) as interval) AS date) AS vencimiento,
	numero,
	saldo,
	0,
	0,
	0,
	0,
	ndocumento,
	vfactura,
	0,
	char_cta,
	id_cta
FROM
(SELECT
	c.fecha,
	c.numero,
	c.idtercero,
	c.nfactura,
	c.dcredito,
	c.vfactura,
	c.tfactura,
	c.tfactura+COALESCE(co.cargos,0)-COALESCE(co.vcomprobante,0) AS saldo,
	c.char_cta,
	c.id_cta,
	c.ndocumento
FROM
        (SELECT
			d.fecha,
			COALESCE(rf.prefijo,d.codigo_tipo)||'-'||d.numero::BIGINT||'-'||coalesce(id.ex_documento,'-') AS numero,
			c.idtercero,
	        c.nfactura,
	        c.dcredito,
	        SUM(c.neto_factura) AS vfactura,
	        SUM(c.total_factura) AS tfactura,
			ac.char_cta,
			ac.id_cta,
			d.ndocumento
        FROM
			cartera c,
			cuentas ac,
			info_documento id,
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
			d.codigo_tipo IN ('FC','1B') and -- PONGO ESTO PARA QUE SE LISTEN LAS FACTURAS DE MIGRACION DE CARTERA CXC y 1B los saldos iniciales de sistecredito
			ac.id_cta=c.id_cta and
			ac.char_cta not in ('28050502') and -- se excluyen los separados Oct 7 2024
			d.ndocumento=c.nfactura AND
			d.ndocumento=id.ndocumento AND
			c.idtercero= (select id::bigint from aux_parametros_query) AND
			d.estado='true' AND
			--c.movimiento=true AND
			c.total_factura>0
	    GROUP BY
			d.fecha,
			COALESCE(rf.prefijo,d.codigo_tipo)||'-'||d.numero::BIGINT,
			id.ex_documento,
			d.ndocumento,
			c.idtercero,
            c.nfactura,
            c.dcredito,
			ac.id_cta,
			ac.char_cta) AS c
LEFT OUTER JOIN
        (SELECT
            c.nfactura,
            SUM(c.abono_comprobante)+SUM(c.dcto_comprobante) AS vcomprobante,
			SUM(c.cargo_comprobante) AS cargos
        FROM
            cartera c,
            documentos d
        WHERE
            c.ncomprobante=d.ndocumento AND
            d.estado='true'
        GROUP BY
            c.nfactura) AS co
ON
        co.nfactura=c.nfactura) AS foo
WHERE
	foo.saldo>0 
ORDER BY
	fecha,
	ndocumento;
			
			
					