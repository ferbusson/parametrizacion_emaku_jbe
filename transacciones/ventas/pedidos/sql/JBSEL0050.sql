--JBSEL0050
drop table if exists aux_prefijos_facturas;
create temp table aux_prefijos_facturas as
		select DISTINCT
	        dsl.codigo_tipo
		from
			documentos_standar ds
		inner join
		    documentos_sucursales dsl
		on
			dsl.id_documento = ds.id_documento
		WHERE
	    	ds.nombre IN ('FELECTRONICAPOS','FCREDITO');


drop table if exists aux_parametros;
create temp table aux_parametros as
    select 
        ndocumento, 
        rf_documento 
    from 
        info_documento i
    where 
        ndocumento = '?'; -- ndocumento del pedido que se esta anulando


drop table if exists aux_validacion_documento;
create temp table aux_validacion_documento as
SELECT 
	1
FROM
	(SELECT
		error_text('No es posible Anular el pedido, se procesó con la factura número: '||foo.codigo_tipo||'-'||foo.numero)
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
			and d.codigo_tipo in (select codigo_tipo from aux_prefijos_facturas)
		where
			i.rf_documento = (select ndocumento from aux_parametros)
			) as foo) as foo;


update
    info_documento
set
    rf_documento = null
where
    ndocumento = (select ndocumento from aux_parametros);

update
    info_documento
set
    procesado = false
where
    ndocumento = (select rf_documento from aux_parametros);