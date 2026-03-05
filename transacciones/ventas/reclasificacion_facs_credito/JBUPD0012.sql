--JBUPD0012
with aux_parametros_update as (
	select
		'?'::character(2) as codigo_tipo, --? ? ? 
		lpad('?',10,'0') as numero,
		'?'::integer as id_cta_ok
), aux_info_documento_emaku as (
select
	d.ndocumento,
	a.id_cta_ok,
	ca.idtercero as id_tercero_factura, -- viene del registro actual en cartera
	case when a.id_cta_ok = 5560 then 830 else td.id end as id_tercero_ok -- cuando el tipo de credito es Sistecredito el tercero se cambia a 830 porque es el que corresponde a Sistecredito si no se deja el de la factura
from
	aux_parametros_update a
inner join
	documentos d
on
	a.codigo_tipo = d.codigo_tipo 
	and a.numero = d.numero
inner join 
	tercero_def td
on
	d.ndocumento = td.ndocumento 
inner join
	cartera ca
on
	d.ndocumento = ca.nfactura
	and ca.ncomprobante is null
limit 1
), aux_datos_actualizacion_la as ( 
select
	la.orden,
	a.id_cta_ok,
	a.id_tercero_factura,
	a.id_tercero_ok 
from
	aux_info_documento_emaku a
inner join
	libro_auxiliar la
on 
	a.ndocumento = la.ndocumento 
inner join
	cuentas cu
on
	la.id_cta = cu.id_cta
where
	la.id_tercero = a.id_tercero_factura
	and cu.char_cta like '1305%'
), aux_datos_actualizacion_ca as ( 
select
	ca.nfactura,
	ca.idtercero,
	ca.id_cta,
	a.id_cta_ok,
	ca.abono_comprobante,
	ca.ncomprobante,
	a.id_tercero_ok
from
	aux_info_documento_emaku a
inner join
	cartera ca
on
	ca.nfactura = a.ndocumento
inner join
	cuentas cu
on
	ca.id_cta = cu.id_cta
where
	ca.idtercero = a.id_tercero_factura	
	and cu.char_cta like '1305%'
), update_libro_auxiliar_factura as (
update --actualiza libro auxiliar de la factura
	libro_auxiliar as la
set
	id_cta = a.id_cta_ok,
	id_tercero = a.id_tercero_ok
from
	aux_datos_actualizacion_la a
where
	la.orden = a.orden
), update_cartera_factura_y_docs_asociados as(
update cartera as ca --actualiza cartera de la factura y los docs asociados
set
	id_cta = a.id_cta_ok,
	idtercero = a.id_tercero_ok
from
	aux_datos_actualizacion_ca a
where
	ca.idtercero = a.idtercero
	and ca.id_cta = a.id_cta 
	and ca.nfactura = a.nfactura
), aux_datos_actualizacion_la_docs_asociados as(
select
	la.orden,
	la.id_cta,
	a.idtercero,
	a.id_cta_ok,
	a.id_tercero_ok
from
	aux_datos_actualizacion_ca a,
	libro_auxiliar la	
where
	la.ndocumento = a.ncomprobante and
	la.ndocumento_enlace = a.nfactura and
	a.ncomprobante is not null and
	la.id_cta = a.id_cta and
	la.id_tercero = a.idtercero and
	la.haber = a.abono_comprobante
)
update --actualiza libro auxiliar de los docs asociados a la factura
	libro_auxiliar as la
set
	id_cta = a.id_cta_ok,
	id_tercero = a.id_tercero_ok
from
	aux_datos_actualizacion_la_docs_asociados a
where
	la.orden = a.orden;