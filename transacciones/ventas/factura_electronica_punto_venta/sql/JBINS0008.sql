insert into
    puntos_tercero(
        ndocumento,
        id_tercero,
        puntos_generados,
        fecha)
select
    foo.ndocumento,
    CASE WHEN TRIM(foo.id_tercero) != '' THEN foo.id_tercero::integer ELSE -1 END as id_tercero,
    foo.puntos_generados,
    foo.fecha
from        
    (select
        '?'::bigint as ndocumento,
        '?'::varchar as id_tercero,
        '?'::numeric as puntos_generados,
        CURRENT_TIMESTAMP as fecha) as foo
WHERE
    foo.puntos_generados > 0
    and TRIM(foo.id_tercero) != '';