DROP TABLE IF EXISTS aux_params_query;
CREATE TEMP TABLE aux_params_query AS
SELECT
	ps.codigo,
	ps.id_prod_serv,
	ps.id_item,
	ps.iva,
	foo.id_bodega
FROM
	prod_serv ps,	
	(SELECT
		'?'::CHARACTER(14) AS codigo,
		'?'::VARCHAR AS id_bodega) AS foo
WHERE
	ps.codigo = foo.codigo;

DROP TABLE IF EXISTS valida_seleccion_bodega;
CREATE TEMP TABLE valida_seleccion_bodega AS
SELECT
	1
FROM
	(SELECT
		error_text('Seleccione la bodega por favor')
	FROM
		aux_params_query a
	WHERE
		TRIM(a.id_bodega) = '') AS foo;
--

DROP TABLE IF EXISTS aux_pinventario_producto;
CREATE TEMP TABLE aux_pinventario_producto AS
SELECT DISTINCT ON (estado) 
		COALESCE(pinventario,0) AS pinventario
	 FROM
		saldos_inventarios((SELECT codigo FROM aux_params_query),(SELECT id_bodega::INT FROM aux_params_query))
	 WHERE
		 estado = 'Activo'
	 ORDER BY
		 estado,
		 fecha DESC,
		 orden DESC;

DROP TABLE IF EXISTS aux_saldo_producto;
CREATE TEMP TABLE aux_saldo_producto AS
SELECT 
	a.id_prod_serv,
	a.id_item,
	a.iva,
	SUM(COALESCE(i.entrada,0))-SUM(COALESCE(i.salida,0)) AS saldo
FROM 
	aux_params_query a
LEFT OUTER JOIN
	inventarios i
ON
	i.id_prod_serv = a.id_prod_serv AND
	i.id_bodega = a.id_bodega::INT
LEFT OUTER JOIN
	documentos d
ON
	i.ndocumento = d.ndocumento AND
	d.estado	
GROUP BY
	a.id_prod_serv,
	a.id_item,
	a.iva;
--
	
SELECT
	TRIM(i.ref_proveedor) AS ref_proveedor,
	TRIM(i.nombre) AS descripcion,
	TRIM(m.descripcion) AS marca,
	TRIM(l.descripcion) AS linea,
	COALESCE(api.pinventario,0) AS pinventario,
	a.iva,
        a.id_prod_serv,
        a.saldo
FROM 
	aux_saldo_producto a,
	item i,
	marcas m,
	linea l
LEFT OUTER JOIN
	aux_pinventario_producto api
ON
	TRUE
WHERE 
	i.id_marca = m.id_marca AND
	i.id_linea = l.id_linea AND
	i.id_item = a.id_item;