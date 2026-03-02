--JBSEL0077
SELECT
	trim(cu.char_cta) as char_cta,
	foo.descripcion
FROM
	cuentas cu,
	(
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