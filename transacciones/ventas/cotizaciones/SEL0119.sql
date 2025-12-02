SELECT 
    ps.codigo,
    substring(it.nombre,1,66) as descripcion,
    cant,
    pventa,
    dp.iva,
    dp.descuento1,
    0.00 as stotal,
    0.00 as v_dto,
    0.00 as neto,
    0.00 as tiva,
    0.00 as total,
    dp.id_prod_serv,
    0.00 as vlrunitarioimpr,
    ps.codigo,
    it.ref_proveedor,
    0.00 AS verde,
    ps.id_asiento_generico,
    0.00 AS basecinco,
    0.00 AS ivacinco,
    0.00 AS basediezynueve,
    0.00 AS ivadiezynueve,
    0.00 AS baseexento,
    0.00 AS ivaexento,
    0.00 AS baseexcluido,
    0.00 AS ivaexcluido,
    0.00,
    1,
    0.00,
    0.00,
    0.00,
    0.00,
    0.00,
    0.00,
    0.00,
    0.00,
	'' as cuenta,
	coalesce(dp.porcentajebp,-1) as porcentajebp,
	coalesce(dp.inc,-1) as inc
    
FROM 
    datos_prod dp,
    documentos d,
    prod_serv ps,
     item it
WHERE 
    dp.ndocumento=d.ndocumento AND
    ps.id_prod_serv=dp.id_prod_serv AND
     it.id_item=ps.id_item AND
    d.codigo_tipo='?' AND
    d.numero=LPAD('?',10,'0')
ORDER BY
	dp.orden;