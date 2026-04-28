--JBSEL0094
with aux_parametros_query as (
select
	'?'::VARCHAR as dias_credito,
	trim('?'::text) as char_cta)
select
	case when a.char_cta in ('13050504') then '30' when a.char_cta in ('13050502') then '75' else TRIM(a.dias_credito) end as dias_credito
from 
	aux_parametros_query a
limit 1;