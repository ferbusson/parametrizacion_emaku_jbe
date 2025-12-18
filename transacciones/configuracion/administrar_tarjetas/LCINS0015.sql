-- DELETE FROM
-- 	tcredito
-- USING
-- 	(SELECT
-- 		TRIM(nombre) AS nombre,
-- 		TRIM(COALESCE(tipo,'--')) AS tipo
-- 	FROM	
-- 		tcredito
-- 	EXCEPT
-- 	SELECT
-- 		TRIM(nombre) AS nombre,
-- 		TRIM(COALESCE(tipo,'--')) AS tipo
-- 	FROM
-- 		tmp_tarjetasdc) AS foo
-- WHERE
-- 	TRIM(tcredito.nombre) = TRIM(foo.nombre) AND
-- 	TRIM(COALESCE(tcredito.tipo,'--')) = TRIM(COALESCE(foo.tipo,'--'));

UPDATE
	tcredito
SET
	nombre = UPPER(TRIM(t.nombre)),
	tipo = UPPER(TRIM(COALESCE(t.tipo,'--'))),
	comision = COALESCE(t.comision,0),
	visible = COALESCE(t.visible,FALSE),
	id_tercero_banco = g.id,
	id_banco = t.id_banco,
	id_cta_rfuente = t.id_cta_rfuente,
	id_cta_rtiva = t.id_cta_rtiva, 
	id_cta_comision = t.id_cta_comision,
	prte_fuente=t.prte_fuente,
	prte_iva=t.prte_iva
FROM
	tmp_tarjetasdc t,
	general g
WHERE
	g.id_char=t.id_tercero_banco AND
	UPPER(TRIM(tcredito.nombre)) = UPPER(TRIM(t.nombre)) AND
	UPPER(TRIM(COALESCE(tcredito.tipo,'--'))) = UPPER(TRIM(COALESCE(t.tipo,'--')));
	
INSERT INTO tcredito(nombre,tipo,comision,visible, id_banco,id_cta_rfuente,id_cta_rtiva, id_cta_comision,id_tercero_banco,prte_fuente,prte_iva)
SELECT
	TRIM(t.nombre),
	TRIM(t.tipo),
	COALESCE(t.comision,0) AS comision,
	COALESCE(t.visible,FALSE) AS visible,
	id_banco,
	id_cta_rfuente,
	id_cta_rtiva,
	id_cta_comision,
	g.id,
	prte_fuente,
	prte_iva
FROM
	(SELECT
		TRIM(nombre) AS nombre,
		TRIM(COALESCE(tipo,'--')) AS tipo
	FROM
		tmp_tarjetasdc
	EXCEPT
	SELECT
		TRIM(nombre) AS nombre,
		TRIM(COALESCE(tipo,'--')) AS tipo
	FROM
		tcredito) AS foo,
	tmp_tarjetasdc t,
	general g
WHERE
	g.id_char=t.id_tercero_banco AND
	TRIM(t.nombre) = TRIM(foo.nombre) AND
	TRIM(t.tipo) = TRIM(foo.tipo);