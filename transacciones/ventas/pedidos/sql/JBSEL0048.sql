--JBSEL0048 SELECT ESTADO DEL DOCUMENTO COTIZACION/PEDIDO
with aux_prefijos_validos as (
	    select
	    	'?'::CHARACTER(2) as codigo_tipo_parametro,
	        dsl.*
		from
			documentos_standar ds
		inner join
		    documentos_sucursales dsl
		on
			dsl.id_documento = ds.id_documento
		WHERE
	    	ds.nombre = 'COTIZACION'
),
aux_parametros_query as (	
    select
        d.*
	from
	    documentos d    
	inner join
		aux_prefijos_validos p
	ON
		d.codigo_tipo = p.codigo_tipo
	WHERE
        d.codigo_tipo = (select codigo_tipo_parametro from aux_prefijos_validos limit 1)
        and d.numero = lpad('?',10,'0')
),
aux_check_exists as (
    SELECT 
        CASE 
            WHEN COUNT(*) = 0 and 
            	(select codigo_tipo_parametro from aux_prefijos_validos limit 1) in (select codigo_tipo from aux_prefijos_validos) THEN 'EL DOCUMENTO NO EXISTE'
            ELSE NULL 
        END as no_existe_mensaje
    FROM aux_parametros_query
)

SELECT 
        case 
            when d.fecha::date + interval '1 day'*id.vencimiento < CURRENT_DATE then 'DOCUMENTO VENCIDO'
            when d.estado = false then 'DOCUMENTO ANULADO'
            when exists (select 1 from info_documento i where i.rf_documento = d.ndocumento) then 'DOCUMENTO YA PROCESADO'
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
            when exists (select 1 from info_documento i where i.rf_documento = d.ndocumento) then true
            else false end
    )

UNION ALL
SELECT 
	no_existe_mensaje as estado_documento
FROM 
	aux_check_exists 
WHERE 
	no_existe_mensaje IS NOT null;
