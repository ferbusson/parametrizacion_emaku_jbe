DROP TABLE IF EXISTS aux_sucursal_base;
CREATE TEMP TABLE aux_sucursal_base AS
SELECT
	ds.id_administracion_sucursales,
	t.codigo,
	ds.id_documento
FROM
	documentos_sucursales ds,
	transacciones t,
	(SELECT
		min(id_administracion_sucursales) AS id_administracion_sucursales
	FROM
		administracion_sucursales) AS foo
WHERE
	ds.id_administracion_sucursales = foo.id_administracion_sucursales AND
	ds.id_transaccion = t.id_transaccion;

DROP TABLE IF EXISTS aux_july_20150707;
CREATE TEMP TABLE aux_july_20150707 AS
SELECT
	dst.nombre,
	COALESCE(foo.codigo,a.codigo) AS codigo,
	foo.codigo_tipo,
	foo.id_administracion_sucursales,
	dst.id_documento
FROM
	documentos_standar dst
LEFT OUTER JOIN
	(SELECT
		dst.nombre,
		t.codigo,
		ds.codigo_tipo,
		a.id_administracion_sucursales,
		dst.id_documento
	FROM
		administracion_sucursales a,
		documentos_sucursales ds,
		documentos_standar dst,
		transacciones t
	WHERE
		a.id_administracion_sucursales = ds.id_administracion_sucursales AND
		dst.activo and
		dst.id_documento = ds.id_documento AND
		ds.id_transaccion = t.id_transaccion AND
		a.nombre = '?') AS foo
ON
	dst.nombre = foo.nombre
LEFT OUTER JOIN
	aux_sucursal_base a
ON
	dst.id_documento = a.id_documento
WHERE
	dst.activo
ORDER BY
	dst.nombre;

UPDATE
	aux_july_20150707
SET
	id_administracion_sucursales = foo.id_administracion_sucursales
FROM
	(SELECT
		id_administracion_sucursales
	FROM
		aux_july_20150707
	WHERE
		id_administracion_sucursales IS NOT NULL) AS foo
WHERE
	aux_july_20150707.id_administracion_sucursales IS NULL;

SELECT
	TRIM(nombre) AS nombre,
	TRIM(codigo) AS codigo,
	TRIM(codigo_tipo) AS codigo_tipo,
	COALESCE(id_administracion_sucursales,0) AS id_administracion_sucursales,
	id_documento
FROM
	aux_july_20150707
ORDER BY
	nombre;