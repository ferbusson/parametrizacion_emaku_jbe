--JBSEL0022

select
    nombre
from
    centrocosto
where
    id_centrocosto::varchar = '?'::varchar
limit 1;