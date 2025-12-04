DROP TABLE IF EXISTS args_cune;
CREATE TEMP TABLE args_cune AS
SELECT
	doc.rf_documento as doc_nm,
	doc.ndocumento as doc_el,
	foo.tercero
FROM 
	(SELECT DISTINCT
		i.ndocumento,
	 	i.rf_documento
	FROM
		info_documento i,
		documentos d,
		documentos d2
	WHERE
		i.ndocumento = '?' AND
		i.rf_documento = d.ndocumento AND
		d.estado AND
		d2.ndocumento = i.rf_documento AND
		d2.estado) AS doc,
	(SELECT 
		(('?'::NUMERIC)*-1)::VARCHAR AS tercero) AS foo;

SELECT
	'NumNIE: '||cune.consecutivo_nomina||
	E'\nFecNIE: '||doc_ne.fecha::DATE||
	E'\nHorNIE: '||doc_ne.hora||
	E'\nNitNIE: '||doc_ne.id_char||
	E'\nDocEmp: '||cune.docadq||
	E'\nValDev: '||mov.devengado||
	E'\nValDed: '||mov.deducido||
	E'\nValTol: '||mov.total||
	E'\nCUNE: '||cune.cufe||
	E'\n'||'https://catalogo-vpfe.dian.gov.co/document/searchqr' AS qr,
	'documentkey='||cune.cufe AS key,
	mov.devengado,
	mov.deducido,
	mov.total
FROM
	(SELECT 
	 	a.doc_nm,
	 	a.doc_el,
		d.fecha::DATE,
		to_char(d.fecha,'HH12:MI:SS')||'-05:00' as hora,
		g.id_char,
		rs.url_busqueda
	FROM	
		registro_software_nomina rs,
		general g,
		documentos d,
		args_cune a
	WHERE
		g.id=1 AND
		d.ndocumento=a.doc_nm) as doc_ne
LEFT OUTER JOIN 
	(SELECT
	 	c.ndocumento,
	 	c.consecutivo_nomina,
	 	c.docadq,
	 	c.cufe,
	 	c.valfac
	 FROM
	 	cufe_documentos c,
	 	args_cune a
	 WHERE	
	 	c.ndocumento = a.doc_el AND
		c.docadq = a.tercero) as cune
ON 
		cune.ndocumento = doc_ne.doc_el
LEFT OUTER JOIN 
	(SELECT
	 	id,
	 	ndocumento,
		id_char,
		SUM(devengado) AS devengado,
		SUM(deducido) AS deducido,
	 	SUM(devengado) - SUM(deducido) AS total
	FROM
		(SELECT
		 	d.ndocumento,
			g.id,
		 	g.id_char,
			SUM(cn.valor) AS devengado,
			0 as deducido
		FROM
			documentos d,
			causacion_nomina cn,
			concepto_causacion c,
			general g,
			movimientos_nomina m,
			division_nomina dn,
			datos_division dd,
			args_cune a
		WHERE
		 	g.id_char=a.tercero AND
			dd.id_tercero=g.id AND
			dn.id_division_nomina=dd.id_division AND
			m.id_movimiento_nomina=c.id_movimiento_nomina AND
			g.id=cn.id_tercero AND
			d.ndocumento=cn.ndocumento AND
			cn.id_concepto_causacion=c.id_concepto_causacion AND
			a.doc_nm=d.ndocumento AND
			(c.id_movimiento_nomina=1 or -- 1 dev obligatorio 5 dev porcentual 7 dev por valor 9 dev provisionado
			c.id_movimiento_nomina=5 or
			c.id_movimiento_nomina=7 or
			c.id_movimiento_nomina=9)
		 GROUP BY 
			d.ndocumento,
			g.id,
		 	g.id_char
		UNION
		SELECT
		 	d.ndocumento,
			g.id,
			g.id_char,
			0 AS devengado,
			sum(cn.valor) as deducido
		FROM
			documentos d,
			causacion_nomina cn,
			concepto_causacion c,
			movimientos_nomina m,
			general g,
			division_nomina dn,
			datos_division dd,
			args_cune a
		WHERE
		 	g.id_char = a.tercero AND
			dd.id_tercero=g.id AND
			dn.id_division_nomina=dd.id_division AND
			m.id_movimiento_nomina=c.id_movimiento_nomina AND
			g.id=cn.id_tercero AND
			d.ndocumento=cn.ndocumento AND
			cn.id_concepto_causacion=c.id_concepto_causacion AND
			a.doc_nm=d.ndocumento AND
			(c.id_movimiento_nomina=2 or -- deducido
			c.id_movimiento_nomina=6 or -- deducido por valor
			c.id_movimiento_nomina=8) -- abonos autorizados
		GROUP BY 
			d.ndocumento,
			g.id,
			g.id_char) AS foo
	 GROUP BY 
	 	id,
	 	ndocumento,
		id_char) AS mov
ON
	mov.ndocumento = doc_ne.doc_nm