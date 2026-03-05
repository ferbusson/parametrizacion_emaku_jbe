-- Tabla temporal de Argumentos
DROP TABLE IF EXISTS ajustes;
CREATE TEMP TABLE ajustes AS
SELECT
	CAST ('?' AS character(10)) AS id_linea,
	CAST ('?' AS character(10)) AS id_grupo,
	CAST ('?' AS character(10)) AS id_sgrupo,
	CAST ('?' AS character(10)) AS id_proveedor,
	CAST ('?' AS character(10)) AS id_marca,
	'?'::VARCHAR AS bodega,
	'?'::VARCHAR AS fecha,
	'?'::character(10) AS reco1,
	'?'::character(10) AS reco2,
	'?'::CHARACTER(1) AS id_filtro; 
	
-- id_filtro:
-- 0 con diferencia entre saldos sis y fisico
-- 1 diferencia > 0
-- 2 diferencia = 0
-- 3 diferencia < 0
-- 4 todos los del filtro


DROP TABLE IF EXISTS aux_productos_filtro;
CREATE TEMP TABLE aux_productos_filtro AS
SELECT DISTINCT -- se pone distinct porque un proveedor puede tenere varias marcas y crea repetidos
	p.codigo,
	TRIM(i.ref_proveedor) AS ref_proveedor,
	i.nombre||' '||m.descripcion AS descripcion,
	m.descripcion AS marca,
	l.descripcion AS linea,
	p.pcosto,
	p.id_prod_serv,
	s.bodega::INTEGER AS bodega,
	s.id_filtro
FROM
	prod_serv p,
	ajustes s,
	linea l,
	marcas m,
	item i
LEFT OUTER JOIN
	proveedor_marca pm
ON
	i.id_marca = pm.id_marca
WHERE
	TRIM(s.reco1) != '' AND
	TRIM(s.reco2) != '' AND
	m.id_marca = i.id_marca AND
	p.id_item = i.id_item AND		
	i.id_linea = l.id_linea AND
	CASE WHEN TRIM(s.id_linea) = '' THEN TRUE ELSE TRIM(s.id_linea)::INTEGER = i.id_linea END AND
	CASE WHEN TRIM(s.id_grupo) = '' THEN TRUE ELSE TRIM(s.id_grupo)::INTEGER = i.id_grupo END AND
	CASE WHEN TRIM(s.id_sgrupo) = '' THEN TRUE ELSE TRIM(s.id_sgrupo)::INTEGER = i.id_sgrupo END AND
	CASE WHEN TRIM(s.id_marca) = '' THEN TRUE ELSE TRIM(s.id_marca)::INTEGER = i.id_marca END AND		
	CASE WHEN TRIM(s.id_proveedor) = '' THEN TRUE ELSE TRIM(s.id_proveedor)::INTEGER = pm.id_proveedor END;
	
	

-- pinventario
-- en vez del pinventario se va a usar ultimo valor entrada Feb 25 2023 se hace en consenso con Dario, esta tabla se deja pero No se usa mas abajo
DROP TABLE IF EXISTS sajuste;
CREATE TEMP TABLE sajuste AS
SELECT
	i.id_bodega,
	i.id_prod_serv,
	i.pinventario
FROM
	inventarios i,
	(SELECT
		max(l.orden) as orden
	FROM
		inventarios l,		
		(SELECT
			l.id_bodega,
			l.id_prod_serv,
			max(l.fecha) as fecha
		FROM
			inventarios l,
			aux_productos_filtro a
		WHERE			
			a.bodega = l.id_bodega AND
			a.id_prod_serv = l.id_prod_serv
		GROUP BY
			l.id_bodega,
			l.id_prod_serv) as f
	WHERE
		f.id_prod_serv=l.id_prod_serv AND
		f.id_bodega=l.id_bodega AND
		f.fecha = l.fecha			
	GROUP BY
		l.id_bodega,
		l.id_prod_serv) AS foo
WHERE
	i.orden = foo.orden;
	
-- ultimo valor entrada Feb 25 2023 se hace en consenso con Dario
DROP TABLE IF EXISTS aux_ultima_ent;
CREATE TEMP TABLE aux_ultima_ent AS
SELECT
	i.id_bodega,
	i.id_prod_serv,
	i.valor_ent
FROM
	inventarios i,
	(SELECT
		max(l.orden) as orden
	FROM
		inventarios l,		
		(SELECT
			l.id_bodega,
			l.id_prod_serv,
			max(l.fecha) as fecha
		FROM
			inventarios l,
			aux_productos_filtro a
		WHERE			
			a.bodega = l.id_bodega AND
			a.id_prod_serv = l.id_prod_serv AND
		 	--l.entrada IS NOT NULL AND 
		 	l.entrada > 0
		GROUP BY
			l.id_bodega,
			l.id_prod_serv) as f
	WHERE
		f.id_prod_serv=l.id_prod_serv AND
		f.id_bodega=l.id_bodega AND
		f.fecha = l.fecha			
	GROUP BY
		l.id_bodega,
		l.id_prod_serv) AS foo
WHERE
	i.orden = foo.orden;

-- LISTADO DE PRODUCTOS
DROP TABLE IF EXISTS pajuste;
CREATE TEMP TABLE pajuste AS
SELECT DISTINCT
	p.codigo,
	p.ref_proveedor,
	p.descripcion,
	p.marca,
	p.linea,
	p.pcosto,
	p.id_prod_serv,
	p.bodega,
	--COALESCE(iv.pinventario,0) AS pinventario,
	COALESCE(iv.valor_ent,0) AS valor_ent,
	p.id_filtro
FROM
	aux_productos_filtro p
LEFT OUTER JOIN
	--sajuste iv
	aux_ultima_ent iv
ON
	p.id_prod_serv=iv.id_prod_serv;
	
DROP TABLE IF EXISTS aux_saldos_productos;
CREATE TEMP TABLE aux_saldos_productos AS
SELECT 
	i.id_bodega,
	i.id_prod_serv,
	COALESCE(SUM(i.entrada),0)-COALESCE(SUM(i.salida),0) AS sdo
FROM 
	inventarios i,
	ajustes a,
	aux_productos_filtro p
WHERE
	i.id_prod_serv = p.id_prod_serv AND
	p.bodega = i.id_bodega AND
	i.fecha<a.fecha::TIMESTAMP
GROUP BY
	i.id_bodega,
	i.id_prod_serv;

SELECT
	foo.codigo,
	substring(foo.ref_proveedor,0,11) AS referencia,
	substring(foo.descripcion,0,40) AS descripcion,
	substring(foo.marca,0,14) AS marca,
	foo.linea,
	COALESCE(foo.sdo,0) as saldosSistema,
	coalesce(rec.cantidad,0) AS saldoFisico,
	0 AS diferencia,
	foo.id_prod_serv,
	COALESCE(foo.valor_ent,foo.pcosto) AS pcosto,
	0 AS cta,
	bodega,
	0,
	0,
	0,
	0,
	NEXTVAL('tagdata') AS tag,
	0,
	--foo.pinventario,
	foo.valor_ent,
    1 AS contador
FROM
	(SELECT
		foo.codigo,
		foo.ref_proveedor,
		foo.descripcion,
		foo.marca,
		foo.linea,
		COALESCE(sdo.sdo,0) AS sdo,
		foo.id_prod_serv,
		foo.pcosto,
		--foo.pinventario,
	 	foo.valor_ent,
		foo.bodega,
		foo.id_filtro
	FROM
		pajuste AS foo
	LEFT OUTER JOIN
		aux_saldos_productos sdo
	ON
		sdo.id_prod_serv=foo.id_prod_serv AND
		sdo.id_bodega = foo.bodega) AS foo
LEFT OUTER JOIN
	(SELECT
		codigo,
		SUM(cantidad) AS cantidad
	FROM
		info_recolectores ir,
		ajustes a,
		documentos d
	WHERE
		d.numero >= LPAD(a.reco1,10,'0') AND
		d.numero <= LPAD(a.reco2,10,'0') AND
		d.estado AND
		d.codigo_tipo = 'DR' AND
		ir.ndocumento=d.ndocumento 
	GROUP BY
		codigo) AS rec
ON
	rec.codigo=foo.codigo
WHERE	
	(foo.id_filtro = '0' AND -- productos con diferencia entre saldo sistema y fisico
	COALESCE(foo.sdo,0) != COALESCE(rec.cantidad,0)) OR
	(foo.id_filtro = '1' AND
	(COALESCE(foo.sdo,0)-COALESCE(rec.cantidad,0))*-1 > 0) OR
	(foo.id_filtro = '2' AND
	(COALESCE(foo.sdo,0)-COALESCE(rec.cantidad,0))*-1 = 0) OR
	(foo.id_filtro = '3' AND
	(COALESCE(foo.sdo,0)-COALESCE(rec.cantidad,0))*-1 < 0) OR
	(foo.id_filtro = '4') -- todos los productos del filtro
ORDER BY
	foo.descripcion;