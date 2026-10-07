--JBUPD0019
drop table if exists aux_parameters_query;
create temp table aux_parameters_query as
select
	coalesce(g.id,-1) as id,
	foo.user_login,
	foo.observacion
from
	(select
        '?'::varchar as descarte,
		'?'::varchar as user_login,
		'?'::varchar as id_char,
		trim('?')::text as observacion) as foo	
join
	general g
on
	g.id_char = foo.id_char;

update
	observaciones_tercero ot
set
	observacion = a.observacion
from
	aux_parameters_query a
where
	ot.id = a.id;


insert into
	observaciones_tercero(
	id,
	modified_by,
	observacion)
select
	a.id,
	a.user_login,
	a.observacion
from
	aux_parameters_query a
where
	not exists (select 1 from observaciones_tercero ot where ot.id = a.id);
