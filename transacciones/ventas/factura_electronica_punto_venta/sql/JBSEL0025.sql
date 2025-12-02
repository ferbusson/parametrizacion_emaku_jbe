--JBSEL0025
with aux_parametros_query as (
SELECT  
    d.ndocumento
FROM
    documentos d
WHERE
    d.codigo_tipo = '?'
    AND d.numero = lpad('?', 10, '0')
),
aux_puntos_tercero as (
select
    -- se usa max para evitar multiples filas ya que el documento puede tener puntos_redimidos y puntos_generados. No debería
    -- haber mas de dos filas por documento (una por cada tipo de punto)
    max(pt.fecha) as fecha_factura,
    min(id_puntos_tercero) as orden,
    coalesce(max(puntos_redimidos), 0) as puntos_redimidos
FROM
    puntos_tercero pt
WHERE
    pt.ndocumento = (SELECT a.ndocumento FROM aux_parametros_query a)
)
select
    (select pt.saldo from 
    puntos_tercero pt where pt.id_puntos_tercero < a.orden and pt.fecha < a.fecha_factura order by pt.id_puntos_tercero desc limit 1)    as puntos_acumulados_antes_factura,
    a.puntos_redimidos
from
    aux_puntos_tercero a;