--JBSEL0011 query factura punto de venta
SELECT 
    ps.codigo,
    substring(it.nombre,0,40) as nombre,
    0 as disponible,
    cant,
    1 as lista,
    pventa,
    dp.iva,
    dp.descuento1,
    0.00 as sub_tot,
    0.00 as v_dcto,
    0.00 as vrtotal,
    0.00 as v_Iva,
    0.00 as gtotal,
    dp.id_prod_serv,
    --CURRENT_TIMESTAMP AS tag,
    --COALESCE(dd.trm,'0.0') AS trm,
    dp.pventa as pventa_imp,
    ps.codigo as codigo_imp,
    it.ref_proveedor,
    0.0 as verde,
    ps.id_asiento_generico,
    0.0 as basecinco,
    0.0 as ivacinco,
    0.0 as basediezynueve,
    0.0 as ivadiezynueve,
    0.0 as baseexentos,
    0.0 as ivaextos,
    0.0 as baseexcluidos,
    0.0 as ivaexcluidos,
    0.0 as netosinbolsa,
    1 AS contador_linea,
    'NA' as char_cta_plataforma,
    coalesce(dp.porcentajebp,-1) as porcentajebp,
    coalesce(dp.inc,-1) as inc,
    0.0 as subtotalsinbolsa,
    pt.es_pintor,
    0.0 as javipuntos
FROM 
    datos_prod dp,
    documentos d,
    tercero_def t,
    perfil_tercero pt,
    prod_serv ps,
    item it,
    marcas mar
WHERE 
    dp.ndocumento=d.ndocumento and
    t.ndocumento=d.ndocumento and
    t.id = pt.id and
    ps.id_prod_serv=dp.id_prod_serv AND
    it.id_item=ps.id_item AND
    it.id_marca=mar.id_marca AND
    codigo_tipo='?' AND
    d.numero=LPAD('?',10,'0')
ORDER BY
	dp.orden;