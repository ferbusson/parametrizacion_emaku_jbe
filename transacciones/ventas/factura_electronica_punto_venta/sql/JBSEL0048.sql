--JBSEL0048 SELECT ESTADO DEL DOCUMENTO COTIZACION/PEDIDO
with aux_parametros_query as (
    SELECT
        d.*
    from
        documentos d
    where
        d.codigo_tipo = '?'
        and d.numero = lpad('?',10,'0')
),
aux_check_exists as (
    SELECT 
        CASE 
            WHEN COUNT(*) = 0 THEN 'EL PEDIDO NO EXISTE'
            ELSE NULL 
        END as no_existe_mensaje
    FROM aux_parametros_query
)

SELECT 
        case 
            when d.fecha::date + interval '1 day'*id.vencimiento < CURRENT_DATE then 'PEDIDO VENCIDO'
            when d.estado = false then 'PEDIDO ANULADO'
            when id.procesado = true then 'PEDIDO YA FACTURADO'
            else
            	''
        end
    as estado_documento
FROM                 
    aux_parametros_query d
inner JOIN
    info_documento id
ON 
    d.ndocumento = id.ndocumento
WHERE
    (SELECT no_existe_mensaje FROM aux_check_exists) IS NULL
    AND (
        case 
            when d.fecha::date + interval '1 day'*id.vencimiento < CURRENT_DATE then true
            when d.estado = false then true
            when id.procesado = true then true
            else false end
    )

UNION ALL

SELECT no_existe_mensaje as estado_documento
FROM aux_check_exists 
WHERE no_existe_mensaje IS NOT NULL;
