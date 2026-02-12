drop table if exists aux_parametros_consulta;
create temp table aux_parametros_consulta as
select
	'?'::varchar as id_tercerofactura,
	'?'::float as valor,
	'?'::varchar as char_cta;

select
	--case when cu.char_cta like '1105%' or cu.char_cta like '11100502%' or cu.char_cta like '11100503%' then 'EFECTIVO' 
		case 
		when cu.char_cta = '11100502' then 'TRANSFERNCIA BANCOLOMBIA'
		when cu.char_cta = '11100504' then 'TRANSFERNCIA AGRARIO'
		when cu.char_cta = '11100505' then 'TRANSFERNCIA DAVIVIENDA'
		when cu.char_cta = '11100506' then 'TRANSFERNCIA DAVIVIENDA'
		when cu.char_cta = '11100507' then 'TRANSFERNCIA BOGOTÁ'		
		when cu.char_cta = '21051004' then 'BCO / BANCOLOMBIA'		
		when cu.char_cta = '21051006' then 'BCO / BANCOLOMBIA'		
		when cu.char_cta = '21051008' then 'BCO / BOGOTÁ'		
		when cu.char_cta = '21051009' then 'BCO / DAVIVIENDA'		
        else 'EFECTIVO'
			end as medio_pago
from
	aux_parametros_consulta a
inner join
	cuentas cu
on
	a.char_cta = cu.char_cta;