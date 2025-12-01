insert into
    puntos_tercero(
        ndocumento,
        id_tercero,
        puntos_redimidos,
        fecha)
select
    foo.ndocumento,
    CASE WHEN TRIM(foo.id_tercero) != '' THEN foo.id_tercero::integer ELSE -1 END as id_tercero,
    foo.puntos_redimidos,
    foo.fecha
from        
    (select
        '?'::bigint as ndocumento,
        '?'::varchar as id_tercero,
        '?'::numeric as puntos_redimidos,
        CURRENT_TIMESTAMP as fecha) as foo
WHERE
    foo.puntos_redimidos > 0
    and TRIM(foo.id_tercero) != '';