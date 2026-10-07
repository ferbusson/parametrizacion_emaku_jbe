--JBUPD0015
with aux_parametros_update as (
 (SELECT
		'?'::BIGINT AS ndocumento_devolucion,
		'?'::BIGINT AS idtercero,
		'?'::BIGINT AS nfactura,
		'?'::FLOAT8 AS abono_comprobante,
		'?'::FLOAT8 AS pdcto_comprobante,
		'?'::FLOAT8 AS dcto_comprobante,
		'?'::FLOAT8 AS pdcto2_comprobante,
		'?'::FLOAT8 AS pdcto3_comprobante,
		'?'::INTEGER id_cta)
)
, aux_ncomprobante_de_factura as(
	select
		ca.ncomprobante
	from 
		cartera ca
	where
		ca.nfactura = (select nfactura from aux_parametros_update)
	limit 1
)
, aux_sumatoria_comprobantes_nfactura_null as(
	select
		ca.ncomprobante,
		ca.idtercero,
		ca.id_cta,
		sum(ca.abono_comprobante) as abono_comprobante
	from
		cartera ca
	where
		ca.ncomprobante = (select ncomprobante from aux_ncomprobante_de_factura)
		and ca.nfactura is null
	group by
		ca.ncomprobante,
		ca.idtercero,
		ca.id_cta
)
, aux_borrar_registros_null_anteriores as(
delete from
	cartera as ca
using
	aux_ncomprobante_de_factura a
where
	ca.ncomprobante = a.ncomprobante and
	ca.nfactura is null
)
--actualiza el registro asociado a la factura para liberarlo y unificar el valor que se separo al hacer la factura
update
	cartera as ca
set
	nfactura = null,
	abono_comprobante = ca.abono_comprobante + coalesce((select abono_comprobante from aux_sumatoria_comprobantes_nfactura_null),0)
from
	aux_parametros_update a
where
	ca.id_cta = a.id_cta
	and ca.idtercero = a.idtercero
	and ca.nfactura = a.nfactura
	and ca.abono_comprobante::numeric(20,2) = a.abono_comprobante::numeric(20,2);
