--JBSEL0092
select
	trim(sigla) as sigla
from 
	info_empleado ie
where
	ie.id::text = '?';
