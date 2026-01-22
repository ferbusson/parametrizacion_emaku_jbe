DROP TABLE IF EXISTS aux_params_cartera;
CREATE TEMP TABLE aux_params_cartera AS
SELECT
	g.id
FROM
	general g
WHERE
	g.id_char = '?';


SELECT
	fecha,
	dcredito,
	vencimiento,
	numero,
	saldo,
	0,
	0,
	0,
	0,
	0,
	0,
	COALESCE(ex_documento,'******') AS ex_documento,
	0,
	0,
	0,
	ndocumento,
	vfactura,
	0,
	char_cta,
	foo.id_cta,
	idtercero,
	ROUND((RANDOM()*100000)::numeric,0),
	CASE WHEN pc.edocumento THEN 'TRUE' ELSE 'FALSE' END AS edocumento,
	CASE WHEN pc.centro THEN 1 ELSE 0 END AS cc,
	CASE WHEN pc.scentro THEN 1 ELSE 0 END AS cc
FROM
	(SELECT
		CAST(fecha AS date) AS fecha,
		CAST(textcat(text(foo.dcredito), text(' dias')) AS text) AS dcredito,
		CAST(fecha + CAST(textcat(text(dcredito), text(' days')) as interval) AS date) AS vencimiento,
		foo.numero,
		saldo,
		' '||if.ex_documento as ex_documento,
		foo.ndocumento,
		vfactura,
		char_cta,
		id_cta,
		idtercero
	FROM
		(SELECT
			c.idtercero,
			c.fecha,
			c.dcredito,
			c.numero,
			c.nfactura,
			c.vfactura,
			c.tfactura,
			c.tfactura+COALESCE(co.vcomprobante,0) AS saldo,
			c.char_cta,
			c.id_cta,
			c.ndocumento
		FROM
			(SELECT
				d.fecha,
				c.dcredito,
				d.codigo_tipo||d.numero::BIGINT AS numero,
				c.nfactura,
				c.idtercero,
				SUM(c.neto_factura) AS vfactura,
				SUM(c.total_factura) AS tfactura,
				ac.char_cta,
				ac.id_cta,
				d.ndocumento
			FROM
				cartera c,
				documentos d,
				cuentas ac,
			 	aux_params_cartera a
			WHERE
				c.idtercero = a.id AND
				ac.char_cta like '2%' AND
				(ac.char_cta  not like '2367%' AND 
				ac.char_cta  not like '2365%' AND
				ac.char_cta  not like '24%') AND
				d.ndocumento=c.nfactura AND
				ac.id_cta=c.id_cta AND
				d.estado AND
				c.total_factura>0
			GROUP BY
				d.fecha,
				c.nfactura,
				c.idtercero,
				c.dcredito,	
				d.codigo_tipo,
				d.numero::BIGINT,
				c.nfactura,
				c.dcredito,
				ac.char_cta,
				ac.id_cta,
				d.ndocumento) AS c
		LEFT OUTER JOIN
			(SELECT
				c.id_cta,
				c.nfactura,
				c.idtercero,
				SUM(COALESCE(c.cargo_comprobante,0))-(SUM(COALESCE(c.abono_comprobante,0))+SUM(COALESCE(c.dcto_comprobante,0))) AS vcomprobante
			FROM
				cartera c,
				documentos d,
			 	aux_params_cartera a
			WHERE
				c.ncomprobante=d.ndocumento AND
			 	c.idtercero = a.id AND
				d.estado='true'
			GROUP BY
				c.id_cta,
				c.nfactura,
				c.idtercero) AS co
		ON
			co.id_cta=c.id_cta AND
			co.nfactura=c.nfactura AND
			co.idtercero=c.idtercero) AS foo
	LEFT OUTER JOIN
		info_documento if
	ON
		if.ndocumento=foo.ndocumento 
	ORDER BY
		fecha) as foo,
	perfil_cta pc
WHERE
	foo.id_cta = pc.id_cta AND
	foo.saldo!=0
ORDER BY
	foo.fecha,
	foo.numero;