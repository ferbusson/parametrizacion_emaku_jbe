--JBSEL0069
drop table if exists aux_parametros_query;
create temp table aux_parametros_query as
select
	d.ndocumento
from
	documentos d
where
	d.codigo_tipo = '?'
	and d.numero = LPAD('?',10,'0');

drop table if exists aux_diascredito_facturas;
create temp table aux_diascredito_facturas as
SELECT	
	c.nfactura,
	c2.dcredito
from
	cartera c2,
	cartera c,
	aux_parametros_query a
where
	a.ndocumento = c.ncomprobante
	and c.nfactura = c2.nfactura
	and c2.ncomprobante is null;


select
	true as seleccion,
	d.fecha::date as fecha,
	CAST(textcat(text(dc.dcredito), text(' dias')) AS text) AS dcredito,
	CAST(d.fecha + CAST(textcat(text(dc.dcredito), text(' days')) as interval) AS date) AS vencimiento,
	d.codigo_tipo||'-'||d.numero::BIGINT||case when id.ex_documento is not null and trim(id.ex_documento,'') != '' then ' / '||id.ex_documento else '' end AS numero,
	ca.saldo_anterior as saldo,
	ca.abono_comprobante as abono,
	ca.pdcto_comprobante,
	ca.dcto_comprobante as valor_descuento,
	0 as total_pagar,
	0 as saldo_factura,
	id.ex_documento as fac_proveedor,
	d.ndocumento,
	ca.saldo_anterior as vfactura,
	ca.abono_comprobante as valor_pago,
	cu.char_cta,
	cu.id_cta,
	round((ca.saldo_anterior/1.19)::numeric,2) as valor_base,
	0 as contador_factura,
	round((ca.saldo_anterior-round((ca.saldo_anterior/1.19)::numeric,2))::numeric,2) as valor_iva
from
	aux_parametros_query a
inner join
	cartera ca
on
	a.ndocumento = ca.ncomprobante 
inner join 
	documentos d
on
	d.ndocumento = ca.nfactura
inner join 
	info_documento id
on
	d.ndocumento = id.ndocumento
inner join 
	cuentas cu
on
	ca.id_cta = cu.id_cta 
inner join
	aux_diascredito_facturas dc
on
	ca.nfactura = dc.nfactura
where
	cu.char_cta like '22%'
	AND ca.abono_comprobante != 0
	and ca.abono_comprobante is not null;


