SELECT
	g.nombre1 AS bodega,
	c.nombre AS temporada,
	foo.flete,
	foo.iva_flete,
    COALESCE(nordencompra,'') AS nordencompra
FROM
	general g,
	clase_cxp c,
	(SELECT DISTINCT
		dp.id_bodega,
		l.id_cta,
		tm.flete,
		tm.iva_flete,
        d2.codigo_tipo||'-'||d2.numero::BIGINT AS nordencompra
	FROM  
		datos_prod dp,
		libro_auxiliar l,
		documentos d,
        info_documento id
	LEFT OUTER JOIN
		transporte_mcia tm
	ON
		id.ndocumento = tm.ndocumento
    LEFT OUTER JOIN
		documentos d2
	ON
		id.rf_documento = d2.ndocumento
	WHERE 
		d.ndocumento = dp.ndocumento AND
        d.ndocumento = id.ndocumento AND
		d.ndocumento = l.ndocumento AND
		d.codigo_tipo='?' AND 
		d.numero=LPAD('?',10,'0')) AS foo
WHERE
	g.id = foo.id_bodega AND
	c.id_cta_cxp = foo.id_cta;