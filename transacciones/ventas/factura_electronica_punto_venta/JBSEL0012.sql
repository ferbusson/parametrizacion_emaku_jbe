-- OPTIMIZED JBSEL0012: Account receivables query with separated documents
-- Improved with CTEs for better readability and performance
-- Compatible with PostgreSQL 9.5+

-- Pre-calculate aux_info_pedido data to avoid repeated joins
WITH aux_info_pedido AS (
    SELECT
        ds2.codigo_tipo AS codigo_tipo_pedido,
        ds3.codigo_tipo AS codigo_tipo_anticipo,
        d.ndocumento AS ndocumento_pedido,
        t.id AS tercero_pedido
    FROM documentos d
    JOIN tercero_def t ON d.ndocumento = t.ndocumento
    JOIN documentos_sucursales ds ON d.codigo_tipo = ds.codigo_tipo
    JOIN documentos_sucursales ds2 ON ds.id_administracion_sucursales = ds2.id_administracion_sucursales
    JOIN documentos_standar dst2 ON dst2.id_documento = ds2.id_documento
    JOIN documentos_sucursales ds3 ON ds.id_administracion_sucursales = ds3.id_administracion_sucursales
    JOIN documentos_standar dst3 ON dst3.id_documento = ds3.id_documento
    WHERE dst2.nombre = 'MOSTRADOR'
      AND dst3.nombre = 'ANTICIPOS FACTURACION'
      AND d.codigo_tipo = '?' 
      and d.numero = lpad('?',10,'0')
),

-- Pre-aggregate comprobante data to improve join performance
comprobantes_agregados AS (
    SELECT
        c.nfactura,
        SUM(COALESCE(c.cargo_comprobante, 0)) - 
        (SUM(COALESCE(c.abono_comprobante, 0)) + SUM(COALESCE(c.dcto_comprobante, 0))) AS vcomprobante
    FROM cartera c
    JOIN documentos d ON c.ncomprobante = d.ndocumento
    WHERE d.estado = true
    GROUP BY c.nfactura
),

-- Base cartera data for both UNION branches
cartera_base AS (
    SELECT
        d.fecha,
        c.dcredito,
        d.codigo_tipo || d.numero AS numero,
        c.nfactura,
        SUM(c.neto_factura) AS vfactura,
        SUM(c.total_factura) AS tfactura,
        ac.char_cta,
        ac.id_cta,
        d.ndocumento,
        'separated' AS source_type
    FROM cartera c
    JOIN documentos d ON d.ndocumento = c.nfactura
    JOIN cuentas ac ON ac.id_cta = c.id_cta
    JOIN aux_info_pedido ns ON c.idtercero = ns.tercero_pedido
    JOIN info_documento id ON id.ndocumento = d.ndocumento
    CROSS JOIN aux_info_pedido qp
    WHERE c.idtercero = qp.tercero_pedido
      AND ac.char_cta ILIKE '2%'
      AND (d.ndocumento = ns.ndocumento_pedido OR id.rf_documento = ns.ndocumento_pedido)
      AND d.estado = true
      AND c.total_factura > 0
    GROUP BY d.fecha, c.nfactura, c.dcredito, d.codigo_tipo, d.numero, 
             ac.char_cta, ac.id_cta, d.ndocumento

    UNION ALL

    SELECT
        d.fecha,
        c.dcredito,
        d.codigo_tipo || d.numero AS numero,
        c.nfactura,
        SUM(c.neto_factura) AS vfactura,
        SUM(c.total_factura) AS tfactura,
        ac.char_cta,
        ac.id_cta,
        d.ndocumento,
        'direct' AS source_type
    FROM cartera c
    JOIN documentos d ON d.ndocumento = c.nfactura
    JOIN cuentas ac ON ac.id_cta = c.id_cta
    JOIN aux_info_pedido ns ON c.idtercero = ns.tercero_pedido
    JOIN info_documento id ON id.ndocumento = d.ndocumento
    CROSS JOIN aux_info_pedido qp
    WHERE c.idtercero = qp.tercero_pedido
      AND ac.char_cta ILIKE '2%'
      AND (d.codigo_tipo = ns.codigo_tipo_pedido OR d.codigo_tipo = ns.codigo_tipo_anticipo)
      AND id.rf_documento IS NULL
      AND d.estado = true
      AND c.total_factura > 0
    GROUP BY d.fecha, c.nfactura, c.dcredito, d.codigo_tipo, d.numero,
             ac.char_cta, ac.id_cta, d.ndocumento
),

-- Calculate balances with comprobantes
cartera_con_saldos AS (
    SELECT
        cb.fecha,
        cb.dcredito,
        cb.numero,
        cb.nfactura,
        cb.vfactura,
        cb.tfactura,
        cb.tfactura + COALESCE(ca.vcomprobante, 0) AS saldo,
        cb.char_cta,
        cb.id_cta,
        cb.ndocumento,
        cb.source_type
    FROM cartera_base cb
    LEFT JOIN comprobantes_agregados ca ON ca.nfactura = cb.nfactura
),

-- Add calculated fields and filter non-zero balances
resultado_final AS (
    SELECT
        CAST(ccs.fecha AS DATE) AS fecha,
        CAST(ccs.dcredito || ' dias' AS TEXT) AS dcredito,
        CAST(ccs.fecha + CAST(ccs.dcredito || ' days' AS INTERVAL) AS DATE) AS vencimiento,
        ccs.numero,
        ccs.saldo,
        COALESCE(' ' || id.ex_documento, '') AS ex_documento,
        ccs.ndocumento,
        ccs.vfactura,
        ccs.char_cta,
        ccs.id_cta
    FROM cartera_con_saldos ccs
    LEFT JOIN info_documento id ON id.ndocumento = ccs.ndocumento
    WHERE ccs.saldo != 0
)

-- Final result with standardized output format
SELECT
    fecha,
    dcredito,
    vencimiento,
    numero,
    saldo,
    saldo,           -- Duplicate column as in original
    0 AS col6,       -- Zero columns as in original
    0 AS col7,
    0 AS col8,
    0 AS col9,
    0 AS col10,
    ex_documento,
    0 AS col12,
    0 AS col13,
    0 AS col14,
    ndocumento,
    vfactura,
    0 AS col17,
    char_cta,
    id_cta
FROM resultado_final
ORDER BY fecha, numero;