DROP TABLE IF EXISTS aux_parametros_consulta;
CREATE TEMP TABLE aux_parametros_consulta AS 
SELECT
	'?'::integer as id,
	'?'::BIGINT AS ndocumento;

SELECT
	TRIM(d.direccion) AS direccion,
	TRIM(m.nombre) AS nombre,
	d.id_direccion
from
	tercero_def td,
	direcciones d,
	municipios m,
	aux_parametros_consulta a
WHERE
	d.municipio=m.municipio AND 
	d.id_dep=m.id_dep AND 
	d.id_pais=m.id_pais AND 
	d.id_direccion = td.id_direccion and 
	td.id = a.id and 
	a.ndocumento != (-1) and
	td.ndocumento = a.ndocumento
UNION ALL
SELECT 
	TRIM(d.direccion) AS direccion,
	m.nombre,
	d.id_direccion 
FROM 
	direcciones d,
	municipios m,
	aux_parametros_consulta a
WHERE 
	d.municipio=m.municipio AND 
	d.id_dep=m.id_dep AND 
	d.id_pais=m.id_pais AND 
	CAST(d.id AS character(10))= a.id::character(10) and
	a.ndocumento = (-1)
ORDER BY
	id_direccion DESC;