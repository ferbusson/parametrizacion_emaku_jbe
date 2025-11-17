DROP TABLE IF EXISTS aux_general;
CREATE TEMP TABLE aux_general AS
SELECT 
	g.id,
	g.id_clase_tercero,
	foo.id_regimen,
	foo.id_tipo_obligacion_responsabilidad,
	foo.id_actividad_economica,
	foo.id_catalogo,
	foo.estado,
	foo.id_pais_procedencia,
	foo.mantener_catalogo,
	foo.es_pintor,
	foo.tiene_precio_base
FROM 
	general g,
	(SELECT
		'?'::CHARACTER(25) as id_char,
		'?'::CHARACTER(1) AS id_regimen,
		'?'::integer as id_tipo_obligacion_responsabilidad,
		'?'::character(3) as id_actividad_economica,
		'?'::bigint as id_catalogo,		
		'?'::boolean as estado,
		'?'::CHARACTER(3) as id_pais_procedencia,
		'?'::BOOLEAN as mantener_catalogo,
		'?'::BOOLEAN as es_pintor,
		'?'::BOOLEAN as tiene_precio_base) as foo
WHERE 
	g.id_char=foo.id_char;
	
INSERT INTO 
	perfil_tercero(
		id,
		id_regimen,
		id_tipo_obligacion_responsabilidad,
		id_actividad_economica,
		id_catalogo,
		estado,
		id_tipo_contribuyente,
		id_pais_procedencia,
		mantener_catalogo,
		es_pintor,
		tiene_precio_base
		) 
SELECT
	id,
	id_regimen,
	id_tipo_obligacion_responsabilidad,
	id_actividad_economica,
	id_catalogo,
	estado,
	CASE WHEN id_clase_tercero = 31 THEN 1 ELSE 2 END AS id_tipo_contribuyente,
	id_pais_procedencia,
	mantener_catalogo,
	es_pintor,
	tiene_precio_base
FROM
	aux_general;