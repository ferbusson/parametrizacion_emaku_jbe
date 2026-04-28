drop table if exists aux_parametros_consulta;
create temp table aux_parametros_consulta as
select
	trim('?')::varchar as parametro;

select 
	case when a.parametro = '' or a.parametro is null then 1 else 0 end
from 
	aux_parametros_consulta a;