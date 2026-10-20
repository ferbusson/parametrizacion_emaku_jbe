INSERT INTO
         retenciones_documento(
                 ndocumento,
                 id_cta,
                 base,
                 valor_base,
                 valor_retencion,
		 		 porcentaje,
		 		id_tercero)
SELECT
	foo.ndocumento,
	foo.id_cta,
	-1 as base,
	foo.valor_base,
	abs(foo.haber-foo.debe) as valor_retencion,
	abs(100 * ROUND(((foo.haber-foo.debe)/foo.valor_base)::numeric,3)) AS porcentaje,
	foo.id_tercero
FROM
	(SELECT
		'?'::BIGINT AS ndocumento,
	 	'?'::VARCHAR AS dcredito, -- solo se pone para descartar el argumento
		'?'::BIGINT AS id_cta,
		'?'::FLOAT8 AS valor_base,	 
		'?'::BOOLEAN AS retencion,
		'?'::INTEGER AS id_tercero,
		'?'::FLOAT8 AS debe,
		'?'::FLOAT8 AS haber) AS foo
WHERE
	foo.retencion;