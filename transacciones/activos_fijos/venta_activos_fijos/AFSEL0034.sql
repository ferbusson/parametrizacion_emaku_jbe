-- AFSEL0034

DROP TABLE IF EXISTS temp_contabilizacion_venta_activos_fijos;
CREATE TABLE temp_contabilizacion_venta_activos_fijos
(       
    id_activo INTEGER,
	valor_compra FLOAT8,
	valor_residual FLOAT8,
	depreciacion_acumulada FLOAT8,
	valor_activo_hoy FLOAT8,
	valor_venta FLOAT8,
	id_tercero VARCHAR
); 

INSERT INTO temp_contabilizacion_venta_activos_fijos (
    id_activo,
	valor_compra,
	valor_residual,
	depreciacion_acumulada,
	valor_activo_hoy,
	valor_venta,
	id_tercero) 
VALUES
?;

DROP TABLE IF EXISTS aux_contrapartida_compra;
CREATE TEMP TABLE aux_contrapartida_compra AS
SELECT
    cu.char_cta,
    'Compra de Activos - Contrapartida compra'::VARCHAR AS detalle,
    CASE WHEN pc.centro THEN cc.codigo ELSE NULL END AS centrocosto,
    CASE WHEN pc.terceros THEN t.id_tercero ELSE 'NULL' END AS id_tercero,
	'NULL'::CHARACTER VARYING(12) AS id_prod_serv,
    CASE WHEN pc.naturaleza THEN t.valor_compra ELSE 0 END AS debe,
    CASE WHEN pc.naturaleza = FALSE THEN t.valor_compra ELSE 0 END AS haber,
    'NULL'::CHARACTER VARYING(12) AS documento,    
    'NA'::CHARACTER(4) AS subcentrocosto,
    'NA'::CHARACTER(6) AS vinculo,
    'NULL'::CHARACTER VARYING(12) AS id_grupo,
    cc.id_centrocosto,
    af.id_activo AS id_activo
FROM
    temp_contabilizacion_venta_activos_fijos t,
    activos_fijos af,
	cuentas_grupos_activos_fijos cgaf,
	operaciones_activos_fijos oaf,
	enlace_centrocosto ecc,
    centrocosto cc,
    perfil_cta pc,
    cuentas cu
WHERE
    t.id_activo = af.id_activo AND
	af.estado AND
	af.id_grupo_activos_fijos = cgaf.id_grupo_activos_fijos AND
	oaf.descripcion = 'Compra de Activos' AND
	oaf.id_operacion_activos_fijos = cgaf.id_operacion_activos_fijos AND
    cgaf.id_cta_debito = cu.id_cta AND
	cu.id_cta = pc.id_cta AND
	af.id_centrocosto = ecc.id_bodega AND
	ecc.id_centrocosto = cc.id_centrocosto;


DROP TABLE IF EXISTS aux_contrapartida_depreciacion;
CREATE TEMP TABLE aux_contrapartida_depreciacion AS
SELECT
    cu.char_cta,
    'Venta de Activos'::VARCHAR AS detalle,
    CASE WHEN pc.centro THEN cc.codigo ELSE NULL END AS centrocosto,
    CASE WHEN pc.terceros THEN t.id_tercero ELSE 'NULL' END AS id_tercero,
	'NULL'::CHARACTER VARYING(12) AS id_prod_serv,
    t.depreciacion_acumulada AS debe,
    0.0 AS haber,
    'NULL'::CHARACTER VARYING(12) AS documento,    
    'NA'::CHARACTER(4) AS subcentrocosto,
    'NA'::CHARACTER(6) AS vinculo,
    'NULL'::CHARACTER VARYING(12) AS id_grupo,
    cc.id_centrocosto,
    af.id_activo AS id_activo
FROM
    temp_contabilizacion_venta_activos_fijos t,
    activos_fijos af,
	enlace_centrocosto ecc,
    centrocosto cc,
    perfil_cta pc,
    cuentas cu
WHERE
    t.id_activo = af.id_activo AND
	af.estado AND
	cu.char_cta = '159220' AND
	cu.id_cta = pc.id_cta AND
	af.id_centrocosto = ecc.id_bodega AND
	ecc.id_centrocosto = cc.id_centrocosto;

DROP TABLE IF EXISTS aux_contrapartida_perdida_o_ganancia;
CREATE TEMP TABLE aux_contrapartida_perdida_o_ganancia AS
SELECT
    cu.char_cta,
    'Venta de Activos'::VARCHAR AS detalle,
    CASE WHEN pc.centro THEN cc.codigo ELSE NULL END AS centrocosto,
    CASE WHEN pc.terceros THEN t.id_tercero ELSE 'NULL' END AS id_tercero,
	'NULL'::CHARACTER VARYING(12) AS id_prod_serv,
    CASE WHEN 
		t.valor_compra-t.depreciacion_acumulada > t.valor_venta THEN 
		t.valor_compra-t.depreciacion_acumulada-t.valor_venta ELSE 0 END AS debe,
    CASE WHEN 
		t.valor_compra-t.depreciacion_acumulada < t.valor_venta THEN 
		t.valor_venta-(t.valor_compra-t.depreciacion_acumulada) ELSE 0 END AS haber,
    'NULL'::CHARACTER VARYING(12) AS documento,    
    'NA'::CHARACTER(4) AS subcentrocosto,
    'NA'::CHARACTER(6) AS vinculo,
    'NULL'::CHARACTER VARYING(12) AS id_grupo,
    cc.id_centrocosto,
    af.id_activo AS id_activo
FROM
    temp_contabilizacion_venta_activos_fijos t,
    activos_fijos af,
	cuentas_grupos_activos_fijos cgaf,
	operaciones_activos_fijos oaf,
	enlace_centrocosto ecc,
	perfil_cta pc,
    centrocosto cc,
    cuentas cu
WHERE
    t.id_activo = af.id_activo AND
	af.estado AND
	cu.id_cta = pc.id_cta AND
	af.id_grupo_activos_fijos = cgaf.id_grupo_activos_fijos AND
	oaf.descripcion = 'Venta de Activos' AND
	oaf.id_operacion_activos_fijos = cgaf.id_operacion_activos_fijos AND
	CASE WHEN 
		t.valor_compra-t.depreciacion_acumulada > t.valor_venta THEN 
		cgaf.id_cta_debito = cu.id_cta ELSE cgaf.id_cta_credito = cu.id_cta END AND
	af.id_centrocosto = ecc.id_bodega AND
	ecc.id_centrocosto = cc.id_centrocosto;

--

SELECT
    *
FROM    
    aux_contrapartida_compra
UNION ALL
SELECT
	*
FROM
	aux_contrapartida_depreciacion
UNION ALL
SELECT
	*
FROM
	aux_contrapartida_perdida_o_ganancia
ORDER BY
    centrocosto,
    char_cta,
    id_tercero,
    id_prod_serv;