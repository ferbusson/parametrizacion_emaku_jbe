--JBUPD0008
with aux_parametros_query as (
    select 
        '?'::bigint as ndocumento,
        '?'::integer as dias_adicionales
)
update
    info_documento as i
set
    vencimiento = (select current_date + apq.dias_adicionales - d.fecha::date)
from
    aux_parametros_query apq
inner join
    documentos d
on
    apq.ndocumento = d.ndocumento
where
    i.ndocumento = apq.ndocumento;
