DROP TABLE IF EXISTS args_cartera;
CREATE TEMP TABLE args_cartera AS
SELECT
	'?'::CHARACTER(1) AS clase,
	'?'::DATE AS ffinal,
	--''::CHARACTER(3) AS zona,
	'?'::CHARACTER(50) AS terceron,
	'?'::CHARACTER(50) AS terceroi;

SELECT
        codigo,
        nombre,
        codigo_tipo||numero::integer||'/'||COALESCE(ex_documento,'*') AS numero,
        DATE(fecha)||'  '||(ffinal::date-fecha::date) AS fecha,
        iva,
        CASE WHEN ffinal::date-fecha::date<=30 THEN saldo ELSE 0 END cat,
        CASE WHEN ffinal::date-fecha::date>30 AND ffinal::date-fecha::date<=60 THEN saldo ELSE 0 END tas,
        CASE WHEN ffinal::date-fecha::date>60 AND ffinal::date-fecha::date<=90 THEN saldo ELSE 0 END san,
        CASE WHEN ffinal::date-fecha::date>90 THEN saldo ELSE 0 END mn,
        saldo
FROM
	(SELECT
		COALESCE(c.codigo,co.codigo) AS codigo,
		COALESCE(c.nombre,co.nombre) AS nombre,
		COALESCE(c.nfactura,co.nfactura) AS nfactura,
		COALESCE(c.iva,0) AS iva,
		COALESCE(c.vfactura,0) AS vfactura,
		COALESCE(co.vcomprobante,0) AS vcomprobante,
		COALESCE(c.vfactura,0)+COALESCE(co.vcomprobante,0) AS saldo,
		c.ex_documento
	FROM
		(SELECT
			c.idtercero,
			g.id_char  AS codigo,
			TRIM(COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.razon_social,'')) AS nombre,
			c.nfactura,
			SUM(c.total_factura-c.neto_factura) AS iva,
			SUM(c.total_factura) AS vfactura,
			i.ex_documento
		FROM
			cartera c,
			documentos d,
			info_documento i,
			general g,
			perfil_tercero pt,
			cuentas cu,
			args_cartera f
		WHERE
			d.ndocumento=i.ndocumento AND
			g.id = pt.id AND
			--(pt.id_zona::CHARACTER(5) = f.zona AND f.zona != '' OR
			--f.zona='') AND
			d.ndocumento=c.nfactura AND
			d.fecha::date <=ffinal::date AND
			d.estado AND
			cu.char_cta LIKE '1305%' AND
			c.id_cta = cu.id_cta AND
			c.idtercero=g.id AND
			(COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.razon_social,'') ILIKE '%'||f.terceron||'%' OR
                         g.id_char = f.terceroi)
		GROUP BY
			ffinal,
			c.idtercero,
			g.id_char,
			TRIM(COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.razon_social,'')),
			c.nfactura,
			i.ex_documento) AS c
	FULL OUTER JOIN
		(SELECT
			c.idtercero,
			g.id_char  AS codigo,
			TRIM(COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.razon_social,'')) AS nombre,
			c.nfactura,
			SUM(cargo_comprobante)-(SUM(c.abono_comprobante)+SUM(c.dcto_comprobante)) AS vcomprobante
		FROM
			cartera c,
			cuentas cu,
			documentos d,
			args_cartera f,
			general g,
			perfil_tercero pt
		WHERE
			pt.id=g.id AND
			--(pt.id_zona::CHARACTER(5) = f.zona AND f.zona != '' OR
			--f.zona='') AND
			g.id=c.idtercero AND
			cu.id_cta=c.id_cta AND
			cu.char_cta like '1305%' AND
			d.fecha::date <= ffinal AND
			c.ncomprobante=d.ndocumento AND
			d.estado AND
			(COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.razon_social,'') ILIKE '%'||f.terceron||'%' OR
                         g.id_char = f.terceroi)
		GROUP BY
			c.nfactura,
			codigo,
			TRIM(COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.razon_social,'')),
			c.idtercero) AS co
	ON
		co.nfactura=c.nfactura AND
		c.idtercero=co.idtercero) AS foo,
	documentos d,
	(SELECT 
		nfactura,
		sum(dcredito) as dcredito
	FROM
		cartera
	GROUP BY
		nfactura) AS c,
	args_cartera ac
WHERE
	foo.nfactura=c.nfactura AND
	foo.nfactura=d.ndocumento AND
	((saldo!=0 AND 
	ac.clase = '0') OR
	(saldo!=0 AND saldo>0 AND ac.clase = '1') OR
	(saldo!=0 AND saldo<0 AND ac.clase = '2'))
ORDER BY
	codigo,
	fecha,
	nombre;
