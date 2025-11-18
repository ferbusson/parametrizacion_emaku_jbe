with aux_parametros as (
    select 
        ndocumento, 
        rf_documento 
    from 
        info_documento 
    where 
        ndocumento = '?' -- ndocumento de la factura que se esta anulando
),
aux_actualiza_rf_documento_factura as (
update
    info_documento
set
    rf_documento = null
where
    ndocumento = (select ndocumento from aux_parametros)
)
update
    info_documento
set
    procesado = false
where
    ndocumento = (select rf_documento from aux_parametros);
