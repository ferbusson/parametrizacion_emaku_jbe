--JBUPD0009
drop table if exists aux_parametros;
create temp table aux_parametros as
    select 
        ndocumento, 
        rf_documento 
    from 
        info_documento i
    where 
        ndocumento = '?'; -- ndocumento de la cotizacion que se esta anulando


drop table if exists aux_validacion_documento;
create temp table aux_validacion_documento as
SELECT 
	1
FROM
	(SELECT
		error_text('No es posible Anular la Cotización, se procesó con el pedido número: '||foo.numero)
	FROM
		(select
			d.codigo_tipo,
			d.numero::bigint as numero
		from
			info_documento i
		inner join
			documentos d
		on
			i.ndocumento = d.ndocumento 
			and d.estado
			and d.codigo_tipo = '00'
		where
			i.rf_documento = (select ndocumento from aux_parametros)
			) as foo) as foo;

