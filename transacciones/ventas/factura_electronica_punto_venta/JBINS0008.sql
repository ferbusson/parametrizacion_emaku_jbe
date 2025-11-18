insert into
    puntos_tercero(
        ndocumento,
        id_tercero,
        puntos,
        fecha)
select
    foo.ndocumento,
    foo.id_tercero,
    foo.puntos,
    foo.fecha
from        
    (select
        ?::bigint as ndocumento,
        ?::integer as id_tercero,
        ?::numeric as puntos,
        CURRENT_TIMESTAMP as fecha) as foo
WHERE
    foo.puntos > 0;