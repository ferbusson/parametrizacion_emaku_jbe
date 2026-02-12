--JBSEL0070
drop table if exists aux_parametros_query;
create temp table aux_parametros_query as
select
	d.ndocumento
from
	documentos d
where
	d.codigo_tipo = '?'
	and d.numero = LPAD('?',10,'0');

select
	true as seleccion,
	d.fecha::date as fecha,
	d.codigo_tipo||'-'||d.numero::BIGINT||case when id.ex_documento is not null and trim(id.ex_documento,'') != '' then ' / '||id.ex_documento else '' end AS numero,
	ca.abono_comprobante as abono
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
where
	cu.char_cta like '13%'
	and ca.abono_comprobante != 0
	and ca.abono_comprobante is not null
order by
	numero;


