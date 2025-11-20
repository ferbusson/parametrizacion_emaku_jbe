insert into
    puntos_tercero(
        ndocumento,
        id_tercero,
        puntos_redimidos,
        fecha)
select
    foo.ndocumento,
    foo.id_tercero,
    foo.puntos_redimidos,
    foo.fecha
from        
    (select
        ?::bigint as ndocumento,
        ?::integer as id_tercero,
        ?::numeric as puntos_redimidos,
        CURRENT_TIMESTAMP as fecha) as foo
WHERE
    foo.puntos_redimidos > 0;