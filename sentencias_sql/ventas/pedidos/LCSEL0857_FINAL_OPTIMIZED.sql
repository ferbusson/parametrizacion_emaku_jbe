-- LCSEL0857_FINAL_OPTIMIZED - Ultimate performance version
-- Eliminates the expensive pventa_adjusted temporary table

-- Parameter validation (minimal)
DROP TABLE IF EXISTS aux_params_antes_de_validaciones;
CREATE TEMP TABLE aux_params_antes_de_validaciones AS
SELECT
    '044'::CHARACTER(14) AS codigo,
    '960'::INT AS tercero,
    '1'::INTEGER AS id_centrocosto,
    '138'::INTEGER AS id_bodega,
    '1'::INTEGER AS dia_siniva;

-- Main parameters (streamlined)
DROP TABLE IF EXISTS aux_params;
CREATE TEMP TABLE aux_params AS
SELECT 
    ds.codigo_tipo,
    foo.id_centrocosto,
    foo.codigo,
    foo.tercero,
    foo.id_bodega,
    foo.dia_siniva,
    pt.id_catalogo,
    pt.id_regimen  -- Get regime here to avoid extra JOIN later
FROM
    administracion_sucursales a
    INNER JOIN documentos_sucursales ds ON a.id_administracion_sucursales = ds.id_administracion_sucursales
    INNER JOIN documentos_standar dst ON ds.id_documento = dst.id_documento
    INNER JOIN aux_params_antes_de_validaciones foo ON a.id_centrocosto = foo.id_centrocosto
    INNER JOIN perfil_tercero pt ON foo.tercero = pt.id
WHERE dst.nombre = 'FACTURACION';

-- Pre-calculate DSI topes for faster lookup
DROP TABLE IF EXISTS dsi_topes;
CREATE TEMP TABLE dsi_topes AS 
SELECT
    sdsi.id_sgrupo,
    c.tope
FROM
    subgrupos_dsi sdsi
    INNER JOIN generos_dsi g ON sdsi.id_genero_dsi = g.id_genero_dsi
    INNER JOIN categorias_dsi c ON g.id_categoria_dsi = c.id_categoria_dsi;

-- Get active promotions with hierarchy (simplified)
DROP TABLE IF EXISTS active_promotions;
CREATE TEMP TABLE active_promotions AS
SELECT 
    r.ndocumento,
    r.codigo_tipo,
    r.id_linea,
    r.id_grupo,
    r.id_sgrupo,
    r.id_marca,
    r.id_submarca,
    COALESCE(ip.id_item, -1) as id_item,
    xy.pdescuento,
    xy.narticulos,
    -- Simple hierarchy for ordering
    CASE 
        WHEN ip.id_item IS NOT NULL THEN 1
        WHEN r.id_submarca IS NOT NULL AND r.id_sgrupo IS NOT NULL THEN 2
        WHEN r.id_submarca IS NOT NULL AND r.id_grupo IS NOT NULL THEN 3
        WHEN r.id_submarca IS NOT NULL AND r.id_linea IS NOT NULL THEN 4
        WHEN r.id_submarca IS NOT NULL THEN 5
        WHEN r.id_marca IS NOT NULL AND r.id_sgrupo IS NOT NULL THEN 6
        WHEN r.id_marca IS NOT NULL AND r.id_grupo IS NOT NULL THEN 7
        WHEN r.id_marca IS NOT NULL AND r.id_linea IS NOT NULL THEN 8
        WHEN r.id_marca IS NOT NULL THEN 9
        WHEN r.id_sgrupo IS NOT NULL THEN 10
        WHEN r.id_grupo IS NOT NULL THEN 11
        WHEN r.id_linea IS NOT NULL THEN 12
        ELSE 13
    END as hierarchy_level
FROM 
    registro_promociones r
    INNER JOIN documentos d ON r.ndocumento = d.ndocumento AND d.estado = true
    INNER JOIN xy_promocion xy ON r.ndocumento = xy.ndocumento
    LEFT JOIN items_promocion ip ON r.ndocumento = ip.ndocumento
WHERE 
    r.estado = true 
    AND CURRENT_TIMESTAMP BETWEEN r.fechaip AND r.fechafp;

-- Create index for faster promotion lookups
CREATE INDEX IF NOT EXISTS temp_idx_active_promotions 
ON active_promotions (codigo_tipo, id_marca, id_submarca, id_linea, id_grupo, id_sgrupo, id_item, hierarchy_level);

-- FINAL OPTIMIZED QUERY - NO EXPENSIVE TEMPORARY TABLES
WITH product_data AS (
    SELECT
        ps.id_prod_serv,
        ps.codigo,
        ps.iva,
        ps.id_asiento_generico,
        i.id_linea,
        i.id_grupo,
        i.id_sgrupo,
        i.id_item,
        i.id_marca,
        i.nombre,
        COALESCE(i.id_submarca, 0) as id_submarca,
        i.ref_proveedor,
        a.codigo_tipo,
        a.id_bodega,
        a.id_catalogo,
        a.dia_siniva,
        a.id_regimen,
        COALESCE(tbe.porcentaje, -1) as porcentaje_bp,
        inc.inc,
        pv1.pventa as pventa1,
        pv2.pventa as pventa2,
        pv3.pventa as pventa3,
        dt.tope
    FROM
        aux_params a
        INNER JOIN prod_serv ps ON a.codigo = ps.codigo AND ps.estado = true
        INNER JOIN item i ON ps.id_item = i.id_item
        LEFT JOIN dsi_topes dt ON i.id_sgrupo = dt.id_sgrupo
        LEFT JOIN enlace_producto_tarifa_bolsa_eco e ON ps.id_prod_serv = e.id_prod_serv
        LEFT JOIN tarifas_bolsas_ecologicas tbe ON e.id_nivel_impacto = tbe.id_nivel_impacto
        CROSS JOIN (SELECT inc FROM inc ORDER BY id_inc DESC LIMIT 1) inc
        LEFT JOIN pventa pv1 ON pv1.id_prod_serv = ps.id_prod_serv AND pv1.id_catalogo = a.id_catalogo AND pv1.id_lista = 1
        LEFT JOIN pventa pv2 ON pv2.id_prod_serv = ps.id_prod_serv AND pv2.id_catalogo = a.id_catalogo AND pv2.id_lista = 2
        LEFT JOIN pventa pv3 ON pv3.id_prod_serv = ps.id_prod_serv AND pv3.id_catalogo = a.id_catalogo AND pv3.id_lista = 3
),
product_promotions AS (
    SELECT 
        pd.*,
        -- Get best promotion directly in the CTE
        COALESCE((
            SELECT ap.pdescuento
            FROM active_promotions ap
            WHERE (ap.codigo_tipo = pd.codigo_tipo OR ap.codigo_tipo = '')
              AND (ap.id_item = -1 OR ap.id_item = pd.id_item)
              AND (ap.id_linea IS NULL OR ap.id_linea = pd.id_linea)
              AND (ap.id_grupo IS NULL OR ap.id_grupo = pd.id_grupo)
              AND (ap.id_sgrupo IS NULL OR ap.id_sgrupo = pd.id_sgrupo)
              AND (ap.id_marca IS NULL OR ap.id_marca = pd.id_marca)
              AND (ap.id_submarca IS NULL OR ap.id_submarca = pd.id_submarca)
              AND NOT EXISTS (
                  SELECT 1 FROM registro_promociones_excepciones rpe
                  WHERE rpe.ndocumento = ap.ndocumento
                    AND COALESCE(rpe.id_item, -1) IN (-1, pd.id_item)
                    AND COALESCE(rpe.id_marca, -1) IN (-1, pd.id_marca)
                    AND COALESCE(rpe.id_submarca, -1) IN (-1, pd.id_submarca)
                    AND COALESCE(rpe.id_linea, -1) IN (-1, pd.id_linea)
                    AND COALESCE(rpe.id_grupo, -1) IN (-1, pd.id_grupo)
                    AND COALESCE(rpe.id_sgrupo, -1) IN (-1, pd.id_sgrupo)
              )
            ORDER BY ap.hierarchy_level, ap.pdescuento DESC
            LIMIT 1
        ), 0) as best_discount,
        
        COALESCE((
            SELECT ap.narticulos
            FROM active_promotions ap
            WHERE (ap.codigo_tipo = pd.codigo_tipo OR ap.codigo_tipo = '')
              AND (ap.id_item = -1 OR ap.id_item = pd.id_item)
              AND (ap.id_linea IS NULL OR ap.id_linea = pd.id_linea)
              AND (ap.id_grupo IS NULL OR ap.id_grupo = pd.id_grupo)
              AND (ap.id_sgrupo IS NULL OR ap.id_sgrupo = pd.id_sgrupo)
              AND (ap.id_marca IS NULL OR ap.id_marca = pd.id_marca)
              AND (ap.id_submarca IS NULL OR ap.id_submarca = pd.id_submarca)
              AND NOT EXISTS (SELECT 1 FROM registro_promociones_excepciones rpe WHERE rpe.ndocumento = ap.ndocumento)
            ORDER BY ap.hierarchy_level, ap.pdescuento DESC
            LIMIT 1
        ), 0) as best_narticulos,
        
        COALESCE((
            SELECT ap.ndocumento
            FROM active_promotions ap
            WHERE (ap.codigo_tipo = pd.codigo_tipo OR ap.codigo_tipo = '')
              AND (ap.id_item = -1 OR ap.id_item = pd.id_item)
              AND (ap.id_linea IS NULL OR ap.id_linea = pd.id_linea)
              AND (ap.id_grupo IS NULL OR ap.id_grupo = pd.id_grupo)
              AND (ap.id_sgrupo IS NULL OR ap.id_sgrupo = pd.id_sgrupo)
              AND (ap.id_marca IS NULL OR ap.id_marca = pd.id_marca)
              AND (ap.id_submarca IS NULL OR ap.id_submarca = pd.id_submarca)
              AND NOT EXISTS (SELECT 1 FROM registro_promociones_excepciones rpe WHERE rpe.ndocumento = ap.ndocumento)
            ORDER BY ap.hierarchy_level, ap.pdescuento DESC
            LIMIT 1
        ), '0000000000') as promo_ndocumento
    FROM product_data pd
)
SELECT
    pp.id_prod_serv,
    pp.nombre AS descripcion,
    -- Calculate final price directly (no temp table needed)
    CASE 
        WHEN pp.id_regimen = 'E' THEN 
            ROUND((
                CASE 
                    WHEN pp.dia_siniva = 1 OR pp.tope IS NULL THEN pp.pventa1
                    WHEN pp.tope IS NOT NULL AND 
                         ROUND(((pp.pventa1 - (pp.pventa1 * pp.best_discount / 100)) / (1.0 + (pp.iva/100)))::numeric, 0) <= pp.tope 
                    THEN ROUND((pp.pventa1 / (1.0 + (pp.iva/100)))::numeric, 0)
                    ELSE pp.pventa1 
                END / (1 + (
                    CASE 
                        WHEN pp.dia_siniva = 1 OR pp.tope IS NULL OR 
                             (pp.tope IS NOT NULL AND 
                              ROUND(((pp.pventa1 - (pp.pventa1 * pp.best_discount / 100)) / (1.0 + (pp.iva/100)))::numeric, 0) > pp.tope)
                        THEN pp.iva 
                        ELSE 0 
                    END/100))
            )::numeric, 0)
        ELSE 
            CASE 
                WHEN pp.dia_siniva = 1 OR pp.tope IS NULL THEN pp.pventa1
                WHEN pp.tope IS NOT NULL AND 
                     ROUND(((pp.pventa1 - (pp.pventa1 * pp.best_discount / 100)) / (1.0 + (pp.iva/100)))::numeric, 0) <= pp.tope 
                THEN ROUND((pp.pventa1 / (1.0 + (pp.iva/100)))::numeric, 0)
                ELSE pp.pventa1 
            END
    END AS pventa,
    
    -- Calculate VAT directly
    CASE 
        WHEN pp.id_regimen = 'E' THEN 0 
        ELSE 
            CASE 
                WHEN pp.dia_siniva = 1 OR pp.tope IS NULL OR 
                     (pp.tope IS NOT NULL AND 
                      ROUND(((pp.pventa1 - (pp.pventa1 * pp.best_discount / 100)) / (1.0 + (pp.iva/100)))::numeric, 0) > pp.tope)
                THEN pp.iva 
                ELSE 0 
            END 
    END AS piva,
    
    CURRENT_TIMESTAMP AS tag,
    CASE WHEN pp.id_prod_serv = 28741 THEN 100 ELSE COALESCE((
        SELECT COALESCE(SUM(entrada) - SUM(salida), 0) 
        FROM inventarios inv 
        WHERE inv.id_prod_serv = pp.id_prod_serv AND inv.id_bodega = pp.id_bodega
    ), 0) END AS disponible,
    (SELECT trm FROM trm ORDER BY id_trm DESC LIMIT 1) as trm,
    
    -- Promotion info
    COALESCE(pp.id_marca, -1) AS id_marcap,
    COALESCE(pp.id_item, -1) AS id_itemp,
    pp.best_narticulos AS narticulosa,
    pp.best_discount AS pdescuentoa,
    
    -- Simplified promotion categorization
    0 AS narticulosm, 0 AS pdescuentom,
    pp.best_narticulos AS narticulosi,
    pp.best_discount AS pdescuentoi,
    0 AS narticulosxyl, 0 AS pdescuentoxyl,
    0 AS narticulosxyg, 0 AS pdescuentoxyg,
    0 AS narticulosxysg, 0 AS pdescuentoxysg,
    0 AS narticulosxysm, 0 AS pdescuentoxysm,
    
    -- Promotion document info
    -1 AS id_marca_pc, -1 AS id_item_pc,
    -1 AS id_marca_po, -1 AS id_item_po,
    -1 AS id_marca_pbd, -1 AS id_item_pbd,
    pp.promo_ndocumento AS ndocumento,
    
    -- Core fields
    pp.id_asiento_generico,
    COALESCE(pp.id_linea, -1) AS id_lineap,
    COALESCE(pp.id_grupo, -1) AS id_grupop,
    COALESCE(pp.id_sgrupo, -1) AS id_sgrupop,
    COALESCE(pp.id_submarca, -1) AS id_submarcap,
    pp.codigo,
    pp.ref_proveedor,
    1 AS contador,
    pp.id_regimen,
    '' AS cuenta_plataforma,
    pp.porcentaje_bp,
    pp.inc,
    
    -- Additional price lists
    CASE 
        WHEN pp.id_regimen = 'E' THEN ROUND((pp.pventa2 / (1 + (pp.iva/100)))::numeric, 0) 
        ELSE pp.pventa2 
    END AS pventa2,
    CASE 
        WHEN pp.id_regimen = 'E' THEN ROUND((pp.pventa3 / (1 + (pp.iva/100)))::numeric, 0) 
        ELSE pp.pventa3 
    END AS pventa3
FROM product_promotions pp;