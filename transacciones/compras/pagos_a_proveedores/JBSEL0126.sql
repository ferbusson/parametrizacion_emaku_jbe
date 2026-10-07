--JBSEL0126
DROP TABLE IF EXISTS aux_parametros_busqueda;
CREATE TEMP TABLE aux_parametros_busqueda AS
select
	d.ndocumento
from
	documentos d
where
	d.codigo_tipo = '?' and
	d.numero = LPAD('?',10,'0');


--
/*
SELECT
	l.id_centrocosto
FROM
	libro_auxiliar l,
	aux_parametros_busqueda a
WHERE
	l.ndocumento = a.ndocumento AND
	l.id_centrocosto IS NOT null
limit 1;
*/

select
	1::integer as id_centrocosto;


