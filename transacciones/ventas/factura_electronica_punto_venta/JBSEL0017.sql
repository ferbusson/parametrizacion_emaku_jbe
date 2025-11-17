drop table if exists aux_parametros;
create temp table aux_parametros as
    SELECT
        d.*
    from
        documentos d
    where
        d.codigo_tipo = '?'
        and d.numero = lpad('?',10,'0');

DROP TABLE IF EXISTS error_msg;
CREATE TEMP TABLE error_msg AS
select 1
from
    (SELECT
		error_text(foo.estado_documento)
	FROM
		(SELECT 
            case 
                when d.fecha::date + interval '1 day'*id.vencimiento < CURRENT_DATE then 'PEDIDO VENCIDO'
                when d.estado = false then 'PEDIDO ANULADO'
                when id.procesado = true then 'PEDIO YA FACTURADO' end as estado_documento
            FROM                 
                aux_parametros d
            inner JOIN
                info_documento id
            ON 
                d.ndocumento = id.ndocumento
            WHERE
                    case 
                        when d.fecha::date + interval '1 day'*id.vencimiento < CURRENT_DATE then true
                        when d.estado = false then true
                        when id.procesado = true then true
                        else false end 
			) AS foo);

 SELECT 
    TRIM(observacion) AS observacion
FROM 
    obs_documento od
WHERE 
    od.ndocumento in (SELECT ndocumento FROM aux_parametros)
limit 1;