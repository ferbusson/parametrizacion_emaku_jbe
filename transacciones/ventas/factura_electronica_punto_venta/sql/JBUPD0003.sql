with aux_parametros_update AS (
    SELECT
        '?'::bigint AS ndocumento_pedido,
        '?'::bigint AS id_vendedor,
        '?'::integer AS vencimiento,
        (select id from general where id_char = trim('?')) AS id_tercero_referente,
        trim('?')::varchar AS ex_documento,
        '?'::bigint AS ndocumento
),  

update_info_documento_factura as (
UPDATE 
    info_documento 
SET 
    rf_documento=a.ndocumento_pedido,
    id_vendedor=a.id_vendedor,
    vencimiento=COALESCE(a.vencimiento,0),
    id_tercero_referente = a.id_tercero_referente,
    ex_documento = trim(a.ex_documento)
FROM
    aux_parametros_update a
WHERE 
	info_documento.ndocumento=a.ndocumento
    )
update
    info_documento
set
    procesado = true
where
    ndocumento = (select ndocumento_pedido from aux_parametros_update);

