SELECT
	trim(cu.char_cta) as char_cta,
	foo.descripcion
FROM
	cuentas cu,
	(/*SELECT
		id_cta,
		descripcion,
		CASE WHEN descripcion = 'CREDITO' THEN -1 ELSE row_number() over (ORDER BY descripcion) END as id
	FROM
		tipo_factura_electronica
	WHERE
		descripcion IN ('CREDITO')
	UNION*/
	SELECT
		pv.id_cta,
		c.nombre AS descripcion,
		(row_number() over (ORDER BY c.nombre))+1 as id
	FROM
		centrocosto c,
		plataformas_virtuales pv
	WHERE
		pv.id_centrocosto = c.id_centrocosto ) AS foo
WHERE
	cu.id_cta = foo.id_cta
ORDER BY
	cu.char_cta;
	--foo.id,
	--foo.descripcion;