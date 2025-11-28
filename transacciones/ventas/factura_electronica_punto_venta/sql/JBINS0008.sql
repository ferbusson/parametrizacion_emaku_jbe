insert into
    puntos_tercero(
        ndocumento,
        id_tercero,
        puntos_generados,
        fecha)
select
    foo.ndocumento,
    foo.id_tercero,
    foo.puntos_generados,
    foo.fecha
from        
    (select
        ?::bigint as ndocumento,
        ?::integer as id_tercero,
        ?::numeric as puntos_generados,
        CURRENT_TIMESTAMP as fecha) as foo
WHERE
    foo.puntos_generados > 0;