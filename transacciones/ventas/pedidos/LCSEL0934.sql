DROP TABLE IF EXISTS aux_parametros_consulta;
CREATE TEMP TABLE aux_parametros_consulta AS 
SELECT
	'?'::integer as id,
	'?'::BIGINT AS ndocumento;

SELECT
	TRIM(d.numero) AS numero,
	d.id_telefono
from
	tercero_def td,
	telefonos d,
	municipios m,
	aux_parametros_consulta a
WHERE
	d.municipio=m.municipio AND 
	d.id_dep=m.id_dep AND 
	d.id_pais=m.id_pais AND 
	d.id_telefono = td.id_telefono and 
	td.id = a.id and 
	a.ndocumento != (-1) and
	td.ndocumento = a.ndocumento
UNION ALL
SELECT 
	TRIM(d.numero) AS numero,
	d.id_telefono
FROM 
	telefonos d,
	municipios m,
	aux_parametros_consulta a
WHERE 
	d.municipio=m.municipio AND 
	d.id_dep=m.id_dep AND 
	d.id_pais=m.id_pais AND 
	CAST(d.id AS character(10))= a.id::character(10) and
	a.ndocumento = (-1)
ORDER BY
	id_telefono DESC;