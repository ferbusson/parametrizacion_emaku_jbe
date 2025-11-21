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
      AND d.codigo_tipo = '00' 
      and d.numero = lpad('10',10,'0')
)

-- Pre-aggregate comprobante data to improve join performance
--comprobantes_agregados AS (
    select
    	d.fecha,
    c.dcredito,
    CAST(d.fecha + CAST(c.dcredito || ' days' AS INTERVAL) AS DATE) AS vencimiento,
    d.codigo_tipo||'-'||d.numero::bigint as numero,
    c.abono_comprobante,
    c.abono_comprobante,           -- Duplicate column as in original
    0 AS col6,       -- Zero columns as in original
    0 AS col7,
    0 AS col8,
    0 AS col9,
    0 AS col10,
    id.ex_documento,
    0 AS col12,
    0 AS col13,
    0 AS col14,
    d.ndocumento,
    0.0 as vfactura,
    0 AS col17,
    cu.char_cta,
    cu.id_cta
    
      --  c.ncomprobante,
        --SUM(COALESCE(c.cargo_comprobante, 0)) - 
        --(SUM(COALESCE(c.abono_comprobante, 0)) + SUM(COALESCE(c.dcto_comprobante, 0))) AS vcomprobante
    FROM cartera c
    JOIN documentos d ON c.ncomprobante = d.ndocumento
    JOIN info_documento id ON d.ndocumento = id.ndocumento
    JOIN cuentas cu ON c.id_cta = cu.id_cta
    join aux_info_pedido a on c.idtercero =  a.tercero_pedido
    WHERE d.estado = true
    --GROUP BY c.ncomprobante
ORDER BY fecha, numero;