--JBSEL0066
/*4 * 1000: 511595-521595 	Debito 
 * 			111005			Credito
 * 
 * 	%: 0.004
 * */

drop table if exists aux_parametros_consulta;
create temp table aux_parametros_consulta as
select
	'?'::varchar as id_tercerofactura,
	'?'::float as valor,
	'?'::varchar as char_cta;

select
	a.char_cta,
	a.valor,
	case when a.char_cta like '1110%' then 0.004 else 0 end as tarifa_gastos_bancarios, -- gastos bancarios
	case when a.char_cta like '1110%' then 0.004 * a.valor else 0 end as total_gravamen,
	a.id_tercerofactura,	
	case when a.char_cta like '1110%' then '53050501' else '-1' end as id_cta_gravamen, -- gastos bancarios
	coalesce(e.id_tercero_banco,-1) as id_tercero_banco
from
	aux_parametros_consulta a
inner join
	cuentas cu
on
	a.char_cta = cu.char_cta 
left join
	enlace_bancos e
on 
	e.id_cta = cu.id_cta ;