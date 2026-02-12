DROP TABLE IF EXISTS aux_parametros_busqueda;
CREATE TEMP TABLE aux_parametros_busqueda AS
SELECT
	'?'::INTEGER AS id_tercero;

DROP TABLE IF EXISTS aux_facs_activas;
CREATE TEMP TABLE aux_facs_activas AS
SELECT
	foo.ndocumento
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
						COALESCE(rf.prefijo,d.codigo_tipo)||'-'||d.numero::BIGINT AS numero,
						c.idtercero,
                        c.nfactura,
                        c.dcredito,
                        SUM(c.neto_factura) AS vfactura,
                        SUM(c.total_factura) AS tfactura,
						ac.char_cta,
						ac.id_cta,
						d.ndocumento
                FROM
				 		aux_parametros_busqueda a,
                       	cartera c,
		       			cuentas ac,
                       	documentos d
                LEFT OUTER JOIN
						resolucion_documento rd
				ON
					d.ndocumento = rd.ndocumento
				LEFT OUTER JOIN
					resolucion_facturacion rf
				ON
					rd.id_resolucion_facturacion = rf.id_resolucion_facturacion 
				WHERE
					ac.id_cta=c.id_cta AND
					d.ndocumento=c.nfactura AND
					c.idtercero = a.id_tercero AND
					d.estado='true' AND
					--c.movimiento=true AND comentado para permitir hacer abonos a sistecredito jbe Ene 7 2026
					c.total_factura>0 AND
					d.codigo_tipo NOT IN ('SP','AR','SS','A1','SU','AU')
				GROUP BY
					d.fecha,
					COALESCE(rf.prefijo,d.codigo_tipo)||'-'||d.numero::BIGINT,
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
				 	aux_parametros_busqueda a,
					cartera c,
					documentos d
                WHERE
				 	c.idtercero = a.id_tercero AND
					c.ncomprobante=d.ndocumento AND
					d.estado='true'
                GROUP BY
                    c.nfactura) AS co
        ON
 	       co.nfactura=c.nfactura) AS foo
WHERE
	foo.saldo > 0 
ORDER BY
	foo.fecha,
	foo.nfactura;

--

SELECT DISTINCT
	l.id_centrocosto
FROM
	libro_auxiliar l,
	aux_facs_activas a
WHERE
	l.ndocumento = a.ndocumento AND
	l.id_centrocosto IS NOT NULL AND
	l.id_centrocosto NOT IN (10,12,9);