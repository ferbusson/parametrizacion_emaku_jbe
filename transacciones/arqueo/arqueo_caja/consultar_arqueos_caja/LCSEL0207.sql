DROP TABLE IF EXISTS args_arqueo_medios;
CREATE TEMP TABLE args_arqueo_medios AS
SELECT
	'?'::BIGINT AS ndocumento;

DROP TABLE IF EXISTS tipo_docs;
CREATE TEMP TABLE tipo_docs AS
SELECT
	dv.codigo_tipo
FROM
	documentos d,
	documentos_standar ds,
	administracion_sucursales ad,
	documentos_sucursales du,
	documentos_sucursales dv,
	args_arqueo_medios a
WHERE
	d.ndocumento = a.ndocumento AND
	ds.id_documento=dv.id_documento AND
	dv.id_administracion_sucursales=ad.id_administracion_sucursales AND
	ad.id_administracion_sucursales=du.id_administracion_sucursales AND
	du.codigo_tipo=d.codigo_tipo AND
	ds.nombre IN ('RETIRO PARCIAL','ENTREGA BASE SENCILLA','REEMPLAZO PAGOS PARCIALES');


DROP TABLE IF EXISTS aux_medios;
CREATE TEMP TABLE aux_medios AS
SELECT
	d.codigo_tipo,
	l.*
FROM
	documentos d,
	documentos aq,
	datos_arqueo da,
	libro_auxiliar l,
	args_arqueo_medios a
WHERE
	a.ndocumento=aq.ndocumento AND
	aq.ndocumento=da.narqueo AND
	da.ndocumento=d.ndocumento AND
	d.estado AND
	aq.estado AND
	l.ndocumento=d.ndocumento;

DROP TABLE IF EXISTS aux_tarjetas;
CREATE TEMP TABLE aux_tarjetas AS
SELECT
	SUM(COALESCE(t.valor,0)) as valor
FROM
	args_arqueo_medios a,
	documentos d,
	datos_arqueo da,
	tarjetas t,
	cuentas c
WHERE
	a.ndocumento = da.narqueo AND
	da.ndocumento = d.ndocumento AND
	d.estado AND
	da.ndocumento = t.ndocumento AND
	c.id_cta = t.id_cta AND
	c.char_cta NOT IN ('28050504');
	/* comento esto en JBE 9 Ene 2026
	AND -- En tarjetas tambien se inserta lo que son tarjetas regalo por eso se descartan porque tienen un campo aparte, ver mas abajo
	c.char_cta NOT LIKE '112005%' AND -- las tarjetas que se usan como transferencias se tratan como Consignaciones Dic 14 2021 Maria Elena
	c.char_cta NOT LIKE '110540%'; --Tambien pasamos Wompi a consignaciones Ene 21 2025
*/ 
-- DROP TABLE IF EXISTS aux_tarjetas;
-- CREATE TEMP TABLE aux_tarjetas AS
-- SELECT
-- 	COALESCE(SUM(debe),0) AS valor
-- FROM
-- 	aux_medios a,
-- 	cuentas c
-- WHERE
-- 	c.id_cta=a.id_cta AND
-- 	c.char_cta LIKE '111005%' AND
-- 	a.codigo_tipo NOT LIKE 'R%';

DROP TABLE IF EXISTS aux_reemplazo_tarjeta;
CREATE TEMP TABLE aux_reemplazo_tarjeta AS
SELECT
	COALESCE(SUM(haber),0) AS valor
FROM
	aux_medios a,
	cuentas c
WHERE
	c.id_cta=a.id_cta AND
	c.char_cta LIKE '111005%' AND
	a.codigo_tipo LIKE 'R%'; -- Los R% son los reemplazos de tarjeta

SELECT
	concepto,
	valor
FROM
	(SELECT
		1 as orden,
		'Efectivo' as concepto,
		COALESCE(SUM(debe)-SUM(haber),0) as valor
	FROM
		aux_medios a,
		cuentas c
	WHERE
		a.codigo_tipo NOT LIKE 'J%' AND -- Se exceptuan los retiros parciales y la entrega de base sencilla
		a.codigo_tipo NOT LIKE 'K%' AND -- Ago 6 2020 luego de revision Ago 04 2020
		c.id_cta=a.id_cta AND
		(c.char_cta='11053501' OR -- Cheques son tratados como efectivo
		c.char_cta='11051501')
	UNION
	SELECT
		2,
		'Tarjetas',
		t.valor-ar.valor AS valor
	FROM
		aux_tarjetas t,
		aux_reemplazo_tarjeta ar
	UNION
	SELECT
		3,
		'Cheques Sodexo Pass',
		COALESCE(SUM(debe),0)
	FROM
		aux_medios a,
		cuentas c
	WHERE
		c.id_cta=a.id_cta AND
		c.char_cta='11052001'
	UNION
	SELECT
		4,
		'Consignaciones',
		COALESCE(SUM(debe),0)
	FROM
		aux_medios a,
		consignaciones co,
		cuentas c
	where
		a.ndocumento = co.ndocumento and
		c.id_cta=a.id_cta AND
		(a.detalle ILIKE '%Consignacion%' OR
	 	c.char_cta ~ '112005.' or 
	 	c.char_cta ~ '110540.') -- transferencias
	UNION
	SELECT
		5,
		'Cheques Big Pass',
		COALESCE(SUM(debe),0)
	FROM
		aux_medios a,
		cuentas c
	WHERE
		c.id_cta=a.id_cta AND
		c.char_cta='11052501'
	
	UNION
	-- SELECT
-- 		6,
-- 		'Tarjetas Regalo (Rcga)',
-- 		COALESCE(SUM(haber),0)
-- 	FROM
-- 		aux_medios a,
-- 		cuentas c
-- 	WHERE
-- 		c.id_cta=a.id_cta AND
-- 		c.char_cta='28050504'

	SELECT
		6,
		'Tarjetas Regalo (Redención)',
		COALESCE(SUM(debe),0)
	FROM
		aux_medios a,
		cuentas c
	WHERE
		c.id_cta=a.id_cta AND
		c.char_cta='28050504'
	UNION
	SELECT
		7,
		'Anticipos Facturados',
		COALESCE(SUM(debe),0)
	FROM
		aux_medios a,
		cuentas c
	WHERE
		c.id_cta=a.id_cta AND
		c.char_cta='28050502'

		) AS f
ORDER BY
	orden;