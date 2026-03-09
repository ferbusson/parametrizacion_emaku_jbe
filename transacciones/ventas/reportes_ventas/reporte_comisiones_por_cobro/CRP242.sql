--CRP242
with aux_parametros_query as (
select
	'?'::date as fechai,
	'?'::date as fechaf,
	trim('?'::text) as sigla
)
,aux_listado_movimientos_ventas as (
select
	a.fechai,
	a.fechaf,
	ie.sigla,
	g.id as id_vendedor,
	g.id_char as id_char_vendedor,
 	trim(coalesce(g.apellido1,'')||' '||coalesce(g.apellido2,'')||' '||coalesce(g.nombre1,'')||' '||coalesce(g.nombre2,'')||' '||coalesce(g.razon_social,'')) as nombre_vendedor,
	d.ndocumento,
	gf.id_char as id_char_tercero_factura,
 	trim(coalesce(gf.apellido1,'')||' '||coalesce(gf.apellido2,'')||' '||coalesce(gf.nombre1,'')||' '||coalesce(gf.nombre2,'')||' '||coalesce(gf.razon_social,'')) as nombre_tercero_factura,
	d.codigo_tipo,
	d.codigo_tipo||'-'||d.numero::bigint as numero_factura,
	d.fecha::date + interval '1 day' * id.vencimiento as vencimiento,
 	case when d.codigo_tipo like 'G%' then SUM(coalesce(haber::numeric,0)) else 0 end as ventas_credito
from
	aux_parametros_query a,
	documentos d
inner join
	info_documento id
on
	d.ndocumento = id.ndocumento
inner join
	tercero_def td
on
	d.ndocumento = td.ndocumento
inner join
	general gf
on
	td.id = gf.id
inner join
	libro_auxiliar la
on 	
	d.ndocumento = la.ndocumento
inner join
	cuentas cu
on
	la.id_cta = cu.id_cta
left join
	info_empleado ie
on 	
	id.id_vendedor = ie.id 
left join
	general g
on
	id.id_vendedor = g.id
where
	d.codigo_tipo like 'G%' and
	cu.char_cta like '4135%' and
	d.estado and
	d.fecha::date between a.fechai and a.fechaf and
	case when a.sigla is null or a.sigla = '' then true else ie.sigla = a.sigla end
group by
	g.id,
	g.id_char,
 	trim(coalesce(g.apellido1,'')||' '||coalesce(g.apellido2,'')||' '||coalesce(g.nombre1,'')||' '||coalesce(g.nombre2,'')||' '||coalesce(g.razon_social,'')),
	d.ndocumento,
	d.codigo_tipo,
	gf.id_char,
 	trim(coalesce(gf.apellido1,'')||' '||coalesce(gf.apellido2,'')||' '||coalesce(gf.nombre1,'')||' '||coalesce(gf.nombre2,'')||' '||coalesce(gf.razon_social,'')),
 	id.vencimiento,
	a.fechai,
	a.fechaf,
	ie.sigla,
	d.codigo_tipo,
 	trim(coalesce(g.nombre1,'')||' '||coalesce(g.nombre2,'')||' '||coalesce(g.apellido1,'')||' '||coalesce(g.apellido2,'')||' '||coalesce(g.razon_social,''))
)
, aux_listado_movimientos_pagos as (
select
	ca.nfactura,
	ca.ncomprobante,
	d2.fecha::date as fecha_pago,
	d2.codigo_tipo||'-'||d2.numero::bigint as numero_recibo,
 	SUM(coalesce(abono_comprobante::numeric,0)) as valor_cobro
from
	aux_listado_movimientos_ventas a
left join
	cartera ca
on
	a.ndocumento = ca.nfactura
left join
	documentos d2
on
	d2.ndocumento = ca.ncomprobante
where
	ca.ncomprobante is not null and
	d2.estado and
	d2.codigo_tipo not like 'M%' AND
	d2.fecha::date between a.fechai and a.fechaf
group by
	ca.nfactura,
	ca.ncomprobante,
	d2.fecha::date,
	d2.codigo_tipo||'-'||d2.numero::bigint
)
, aux_cruce_facturas_con_pagos as (
select
	a.fechai,
	a.fechaf,
	a.sigla,
	a.id_char_vendedor,
 	a.nombre_vendedor,
	a.id_char_tercero_factura,
 	a.nombre_tercero_factura,
	a.codigo_tipo,
	a.numero_factura,
	a.vencimiento,
	p.fecha_pago,
	(p.fecha_pago::date - a.vencimiento::date) as dias,
	p.numero_recibo,
	p.valor_cobro,
	min(c.id_comision) as id_comision
from
	aux_listado_movimientos_ventas a
inner join
	aux_listado_movimientos_pagos p
on
	a.ndocumento = p.nfactura
inner join
	comisiones_vendedores c
on
	a.id_vendedor = c.id_vendedor
where
	(p.fecha_pago::date - a.vencimiento::date) <= c.dias_pago 
group by
	a.fechai,
	a.fechaf,
	a.sigla,
	a.id_char_vendedor,
 	a.nombre_vendedor,
	a.id_char_tercero_factura,
 	a.nombre_tercero_factura,
	a.codigo_tipo,
	a.numero_factura,
	a.vencimiento,
	p.fecha_pago,
	p.fecha_pago::date,
	a.vencimiento::date,
	p.numero_recibo,
	p.valor_cobro
)
select
	a.fechai,
	a.fechaf,
	a.sigla,
	a.id_char_vendedor,
 	a.nombre_vendedor,
	a.id_char_tercero_factura,
 	a.nombre_tercero_factura,
	a.codigo_tipo,
	a.numero_factura,
	a.vencimiento,
	a.fecha_pago,
	a.dias,
	a.numero_recibo,
	a.valor_cobro,
	c.pcomision,
	round((a.valor_cobro * (c.pcomision / 100))::numeric,0) as valor_comision
from
	aux_cruce_facturas_con_pagos a
inner join
	comisiones_vendedores c
on
	a.id_comision = c.id_comision;