--LCSEL0602 — variante DETALLE por bodega (una sola)
--
-- Diferencias vs informe_inventario_bodegas_por_tercero_marca.sql:
--   1. Parámetro id_bodega ES OBLIGATORIO. Debe ser una de {138,140,241,243,245}.
--      Se valida al inicio y aborta con RAISE EXCEPTION si viene vacío/nulo/inválido.
--      Motivo: sin filtro por bodega el resultado detallado sería masivo.
--   2. Elimina aux_resultado_final_detallado — el SELECT final devuelve el detalle
--      directamente (línea a línea) en lugar de la suma agregada del valor.

DROP TABLE IF EXISTS aux_params_reporte;
CREATE TEMP TABLE aux_params_reporte AS
SELECT
    '?'::TIMESTAMP AS fecha_corte,
    '?'::INTEGER AS id_bodega,           -- OBLIGATORIO: 138, 140, 241, 243 o 245
    '?'::VARCHAR(25) AS id_char,
    '?'::VARCHAR(10) AS id_marca,
    '?'::SMALLINT AS bandera_saldo;     -- -1: TODOS, 0: saldo 0, 1: con saldo
/*
138 | P-PRINCIPAL
140 | P-BODEGA PEDIDOS  (solo pedidos O% genuinamente abiertos)
241 | P-CARRERA21
243 | P-CCARPINTE
245 | P-AMERICAS
*/


-- Validación: id_bodega obligatorio y dentro del set permitido
DO $$
DECLARE v_bodega INTEGER;
BEGIN
    SELECT id_bodega INTO v_bodega FROM aux_params_reporte;
    IF v_bodega IS NULL OR v_bodega NOT IN (138, 140, 241, 243, 245) THEN
        RAISE EXCEPTION 'Parámetro id_bodega es obligatorio y debe ser uno de {138, 140, 241, 243, 245}. Recibido: %', v_bodega;
    END IF;
END $$;


DROP TABLE IF EXISTS aux_marcas_y_proveedores;
CREATE TEMP TABLE aux_marcas_y_proveedores AS
SELECT
    m.id_marca,
    m.descripcion,
    array_agg(coalesce(g.id_char, '--')) AS nitcc_proveedor_array,
    string_agg(TRIM(COALESCE(g.nombre1,'--')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.razon_social,'')),' | ') AS proveedor
FROM
    marcas m
LEFT JOIN proveedor_marca pm ON m.id_marca = pm.id_marca
LEFT JOIN general g ON pm.id_proveedor = g.id
GROUP BY
    m.id_marca,
    m.descripcion
ORDER BY
    m.id_marca;


-- Bodega 140: productos cuyo último pedido O% en bodega 140 (antes del corte) está activo
-- y no tiene ninguna factura (G% o Z%, d.estado=true) emitida antes o en fecha_corte.
DROP TABLE IF EXISTS aux_pedidos_abiertos_b140;
CREATE TEMP TABLE aux_pedidos_abiertos_b140 AS
SELECT DISTINCT ON(i.id_prod_serv)
    i.id_prod_serv,
    i.ndocumento        AS ndocumento_pedido,
    d.numero            AS numero_pedido,
    d.fecha::date       AS fecha_pedido,
    a.fecha_corte::date - d.fecha::date                         AS dias_abierto,
    idoc.vencimiento                                            AS dias_vigencia,
    idoc.vencimiento - (a.fecha_corte::date - d.fecha::date)   AS dias_restantes
FROM inventarios i
JOIN documentos d ON d.ndocumento = i.ndocumento AND d.estado = true
LEFT JOIN info_documento idoc ON idoc.ndocumento = d.ndocumento,
    aux_params_reporte a
WHERE i.id_bodega = 140
  AND d.codigo_tipo LIKE 'O%'
  AND i.fecha::date <= a.fecha_corte
  AND NOT EXISTS (
      SELECT 1
      FROM info_documento idoc2
      JOIN documentos dfact ON dfact.ndocumento = idoc2.ndocumento AND dfact.estado = true
      WHERE idoc2.rf_documento = d.ndocumento
        AND dfact.fecha::date <= a.fecha_corte
  )
ORDER BY i.id_prod_serv, i.fecha DESC, i.orden DESC;


DROP TABLE IF EXISTS aux_listado_productos;
CREATE TEMP TABLE aux_listado_productos AS
SELECT
    iv.id_bodega,
    g2.nombre1 AS nombre_bodega,
    p.id_prod_serv,
    array_to_string(m.nitcc_proveedor_array, chr(10)) AS nitcc_proveedor,
    m.proveedor,
    m.descripcion AS marca,
    COALESCE(sm.descripcion,'') AS submarca,
    l.descripcion AS linea,
    gr.descripcion AS grupo,
    sg.descripcion AS subgrupo,
    p.codigo,
    CASE WHEN p.estado THEN 'Activo' ELSE 'Inactivo' END AS estado,
    p.pcosto,
    i.ref_proveedor AS referencia,
    i.nombre AS descripcion,
    sum(COALESCE(iv.entrada, 0)) AS entrada,
    sum(COALESCE(iv.salida,  0)) AS salida
FROM
    aux_marcas_y_proveedores m,
    linea l,
    aux_params_reporte a,
    grupo gr,
    sgrupo sg,
    prod_serv p,
    inventarios iv,
    documentos d,
    general g2,
    item i
LEFT OUTER JOIN
    submarcas sm ON i.id_submarca = sm.id_submarca
WHERE
    i.id_linea = l.id_linea AND
    i.id_grupo = gr.id_grupo AND
    d.ndocumento = iv.ndocumento AND
    d.estado AND
    i.id_sgrupo = sg.id_sgrupo AND
    i.id_marca = m.id_marca AND
    p.id_item = i.id_item AND
    iv.id_prod_serv = p.id_prod_serv AND
    CAST(iv.fecha AS TIMESTAMP) <= a.fecha_corte AND
    iv.id_bodega = a.id_bodega AND
    -- Bodega 140: solo productos con pedido genuinamente abierto
    (iv.id_bodega != 140 OR iv.id_prod_serv IN (SELECT id_prod_serv FROM aux_pedidos_abiertos_b140)) AND
    CASE WHEN TRIM(a.id_char) = '' THEN TRUE ELSE a.id_char = any(nitcc_proveedor_array) END AND
    CASE WHEN TRIM(a.id_marca) = '' THEN TRUE ELSE m.id_marca::VARCHAR = a.id_marca END AND
    iv.id_bodega = g2.id
GROUP BY
    iv.id_bodega,
    g2.nombre1,
    p.id_prod_serv,
    m.nitcc_proveedor_array,
    m.proveedor,
    m.descripcion,
    COALESCE(sm.descripcion,''),
    l.descripcion,
    gr.descripcion,
    sg.descripcion,
    p.codigo,
    CASE WHEN p.estado THEN 'Activo' ELSE 'Inactivo' END,
    p.pcosto,
    i.ref_proveedor,
    i.nombre;


DROP TABLE IF EXISTS aux_saldos_productos;
CREATE TEMP TABLE aux_saldos_productos AS
SELECT DISTINCT ON(i.id_bodega, i.id_prod_serv)
    i.id_bodega,
    i.id_prod_serv,
    i.pinventario
FROM
    inventarios i
    JOIN documentos d ON d.ndocumento = i.ndocumento AND d.estado = true,
    aux_listado_productos lp,
    aux_params_reporte a
WHERE
    lp.id_prod_serv = i.id_prod_serv AND
    lp.id_bodega    = i.id_bodega AND
    i.id_bodega = a.id_bodega AND
    (i.id_bodega != 140 OR i.id_prod_serv IN (SELECT id_prod_serv FROM aux_pedidos_abiertos_b140)) AND
    i.fecha::DATE <= a.fecha_corte
ORDER BY
    i.id_bodega,
    i.id_prod_serv,
    i.fecha DESC,
    i.orden DESC;


DROP TABLE IF EXISTS aux_vsaldo_delta;
CREATE TEMP TABLE aux_vsaldo_delta AS
SELECT
    i.id_bodega,
    i.id_prod_serv,
    round(sum(COALESCE(i.entrada,0)*COALESCE(i.valor_ent,0)
            - COALESCE(i.salida,0)*COALESCE(i.valor_sal,0))::numeric, 2) AS valor_saldo
FROM
    inventarios i
    JOIN documentos d ON d.ndocumento = i.ndocumento AND d.estado = true,
    aux_listado_productos lp,
    aux_params_reporte a
WHERE
    lp.id_prod_serv = i.id_prod_serv AND
    lp.id_bodega    = i.id_bodega AND
    i.id_bodega = a.id_bodega AND
    (i.id_bodega != 140 OR i.id_prod_serv IN (SELECT id_prod_serv FROM aux_pedidos_abiertos_b140)) AND
    i.fecha::DATE <= a.fecha_corte
GROUP BY i.id_bodega, i.id_prod_serv;


DROP TABLE IF EXISTS aux_fecha_ult_venta;
CREATE TEMP TABLE aux_fecha_ult_venta AS
SELECT DISTINCT ON(dp.id_prod_serv)
    dp.id_prod_serv,
    dp.id_bodega,
    d.fecha
FROM
    datos_prod dp,
    documentos_standar dst,
    documentos_sucursales ds,
    documentos d,
    aux_listado_productos lp,
    aux_params_reporte a
WHERE
    dst.id_documento = ds.id_documento AND
    dst.nombre IN ('CAMBIOS','FACTURACION','FCONTINGENCIA','FCONTINGENCIAE','FCREDITO','FELECTRONICAPOS','FMANUAL','REMISIONES VENTA','SEPARADOS') AND
    d.ndocumento = dp.ndocumento AND
    ds.codigo_tipo = d.codigo_tipo AND
    d.estado AND
    d.fecha::DATE <= a.fecha_corte AND
    dp.id_bodega IN (138, 241, 243, 245) AND
    lp.id_prod_serv = dp.id_prod_serv
ORDER BY
    dp.id_prod_serv,
    d.fecha DESC;


DROP TABLE IF EXISTS aux_pinventario_ultima_entrada_productos;
CREATE TEMP TABLE aux_pinventario_ultima_entrada_productos AS
SELECT DISTINCT ON(i.id_prod_serv)
    i.id_prod_serv,
    i.fecha::date AS fecha_ult_compra,
    i.valor_ent AS pinventario
FROM
    documentos d,
    inventarios i,
    aux_listado_productos lp,
    aux_params_reporte a
WHERE
    d.ndocumento = i.ndocumento AND
    d.estado AND
    d.codigo_tipo IN ('EA','RC','IM','AT','IP','AF','AO') AND
    lp.id_prod_serv = i.id_prod_serv AND
    i.fecha::DATE <= a.fecha_corte
ORDER BY
    i.id_prod_serv,
    i.fecha DESC;


DROP TABLE IF EXISTS aux_pinventario_productos_bonificados;
CREATE TEMP TABLE aux_pinventario_productos_bonificados AS
SELECT DISTINCT ON(i.id_prod_serv)
    i.id_prod_serv,
    i.valor_ent AS pinventario
FROM
    documentos d,
    inventarios i,
    aux_pinventario_ultima_entrada_productos apb,
    aux_params_reporte a
WHERE
    d.ndocumento = i.ndocumento AND
    d.estado AND
    d.codigo_tipo IN ('EA','RC','IM','AT','IP','AF','AO') AND
    apb.id_prod_serv = i.id_prod_serv AND
    apb.pinventario = 0 AND
    i.valor_ent > 0 AND
    i.fecha::DATE <= a.fecha_corte
ORDER BY
    i.id_prod_serv,
    i.fecha DESC;


-- SELECT final: detalle por producto/bodega (reemplaza aux_resultado_final_detallado)
SELECT
    foo.nombre_bodega,
    foo.nitcc_proveedor,
    foo.proveedor,
    foo.marca,
    foo.submarca,
    foo.linea,
    foo.grupo,
    foo.subgrupo,
    foo.codigo,
    foo.referencia,
    foo.descripcion,
    ROUND(COALESCE(a.pinventario, 0)::NUMERIC, 2) AS pcosto,
    CASE
        WHEN ROUND(aue.pinventario::NUMERIC,2) > 0 THEN ROUND(aue.pinventario::NUMERIC,2)
        WHEN ROUND(apb.pinventario::NUMERIC,2) > 0 THEN ROUND(apb.pinventario::NUMERIC,2)
        WHEN foo.pcosto > 0                         THEN ROUND(foo.pcosto::NUMERIC,2)
        ELSE 0
    END AS pcosto_ult_compra,
    foo.entrada,
    foo.salida,
    COALESCE(foo.entrada, 0) - COALESCE(foo.salida, 0) AS saldo,
    ROUND(COALESCE(vd.valor_saldo, 0)::NUMERIC, 2) AS vsaldo,
    COALESCE(pv.pventa, 0) AS pventa,
    COALESCE(afu.fecha::VARCHAR, 'NA') AS ult_fecha_venta,
    foo.estado,
    COALESCE(aue.fecha_ult_compra::VARCHAR, 'NA') AS fecha_ult_compra,
    current_date - aue.fecha_ult_compra AS dias_en_inventario,
    pab.numero_pedido,
    pab.fecha_pedido,
    pab.dias_abierto,
    pab.dias_vigencia,
    pab.dias_restantes
FROM
    aux_params_reporte apr,
    aux_listado_productos AS foo
LEFT OUTER JOIN
    aux_saldos_productos a
    ON foo.id_prod_serv = a.id_prod_serv AND foo.id_bodega = a.id_bodega
LEFT OUTER JOIN
    aux_pinventario_ultima_entrada_productos aue
    ON foo.id_prod_serv = aue.id_prod_serv
LEFT OUTER JOIN
    aux_pinventario_productos_bonificados apb
    ON foo.id_prod_serv = apb.id_prod_serv
LEFT OUTER JOIN
    pventa pv
    ON foo.id_prod_serv = pv.id_prod_serv AND pv.id_catalogo = 1 AND pv.id_lista = 1
LEFT OUTER JOIN
    aux_fecha_ult_venta afu
    ON foo.id_prod_serv = afu.id_prod_serv AND foo.id_bodega = afu.id_bodega
LEFT OUTER JOIN
    aux_vsaldo_delta vd
    ON foo.id_prod_serv = vd.id_prod_serv AND foo.id_bodega = vd.id_bodega
LEFT OUTER JOIN
    aux_pedidos_abiertos_b140 pab
    ON foo.id_prod_serv = pab.id_prod_serv AND foo.id_bodega = 140
WHERE
    (apr.bandera_saldo =  0 AND ABS(COALESCE(foo.entrada,0) - COALESCE(foo.salida,0)) < 0.001) OR
    (apr.bandera_saldo =  1 AND ABS(COALESCE(foo.entrada,0) - COALESCE(foo.salida,0)) >= 0.001) OR
    (apr.bandera_saldo = -1)
ORDER BY
    nombre_bodega,
    proveedor,
    marca,
    submarca,
    linea,
    grupo,
    subgrupo,
    descripcion;
