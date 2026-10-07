--inserta movimiento inverso al registrado en cartera
--ndocumento_dsno: registro ya existente en cartera
--ndocumento_devolucion: ndocumento de la dev que esta siendo registrada
with aux_parametro_insercion_cartera as(
select	
	'?'::bigint as ndocumento_devolucion,
	'?'::bigint as ndocumento_dsno
)
--aux_datos_cartera_por_nfactura
, aux_datos_cartera_por_nfactura as (
select
	ca.idtercero,
	ca.nfactura,
	ca.id_cta,
	a.ndocumento_devolucion,
	sum(total_factura) as total_factura
from
	cartera ca
join
	aux_parametro_insercion_cartera a
on 
	ca.nfactura = a.ndocumento_dsno
group by
	ca.idtercero,
	ca.nfactura,
	ca.id_cta,
	a.ndocumento_devolucion) 
	
--aux_datos_cartera_por_ncomprobante	
, aux_datos_cartera_por_ncomprobante as (
select
	ca.idtercero,
	ca.nfactura,
	ca.ncomprobante,
	ca.id_cta,
	a.ndocumento_devolucion,
	sum(ca.abono_comprobante) as abono_comprobante
from
	cartera ca
join
	aux_parametro_insercion_cartera a
on 
	ca.ncomprobante = a.ndocumento_dsno
group by
	ca.idtercero,
	ca.nfactura,
	ca.ncomprobante,
	ca.id_cta,
	a.ndocumento_devolucion) 
	
--aux_insert_cartera_abono_comprobante	
, aux_insert_cartera_abono_comprobante as(
insert into
	cartera as ca(
	idtercero,
	nfactura,
	id_cta,
	ncomprobante,
	abono_comprobante)
select
	a.idtercero,
	a.nfactura,
	a.id_cta,
	a.ndocumento_devolucion,
	total_factura as abono_comprobante
from
	aux_datos_cartera_por_nfactura a)

-- inserta cartera con abono_comprobante para anular abono anterior
insert into
	cartera as ca(
	idtercero,
	nfactura,
	id_cta,
	ncomprobante,
	abono_comprobante)
select
	a.idtercero,
	a.nfactura,
	a.id_cta,
	a.ndocumento_devolucion,
	abono_comprobante*-1 as abono_comprobante
from
	aux_datos_cartera_por_ncomprobante a;