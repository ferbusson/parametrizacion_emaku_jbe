with aux_parametros_update AS (
    SELECT
        '?'::bigint AS id_vendedor,
        '?'::integer AS vencimiento,
        (select id from general where id_char = trim('?')) AS id_tercero_referente,
        trim('?')::varchar AS ex_documento,
        '?'::bigint AS ndocumento_cotizacion,
        '?'::bigint AS ndocumento
),  
update_info_documento_factura as (
UPDATE 
    info_documento 
SET 
    id_vendedor=a.id_vendedor,
    vencimiento=COALESCE(a.vencimiento,0),
    id_tercero_referente = a.id_tercero_referente,
    ex_documento = trim(a.ex_documento),
    rf_documento = a.ndocumento_cotizacion
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
    ndocumento = (select ndocumento_cotizacion from aux_parametros_update);
