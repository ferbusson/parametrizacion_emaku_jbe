INSERT INTO contacto_pedidos (
	ndocumento,
    id_tercero,
    telefono,
    direccion)
select
	ndocumento,
    id_tercero,
    telefono,
    direccion
from
	(select
	    '?'::bigint as ndocumento,
	    '?'::integer as id_tercero,
	    '?'::text as telefono,
	    '?'::text as direccion) as foo
where
	telefono is not null
	or direccion is not null;