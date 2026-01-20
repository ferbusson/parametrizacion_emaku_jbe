DROP TABLE IF EXISTS args_arqueo_medios;
CREATE TEMP TABLE args_arqueo_medios AS
SELECT
	'?'::VARCHAR(2) AS codigo_tipo,
	'?'::VARCHAR(10) AS numero;

DROP TABLE IF EXISTS tipo_docs;
CREATE TEMP TABLE tipo_docs AS
SELECT
	dv.codigo_tipo
FROM
	documentos_standar ds,
	administracion_sucursales ad,
	documentos_sucursales du,
	documentos_sucursales dv,
	args_arqueo_medios a
WHERE
	ds.id_documento=dv.id_documento AND
	dv.id_administracion_sucursales=ad.id_administracion_sucursales AND
	ad.id_administracion_sucursales=du.id_administracion_sucursales AND
	du.codigo_tipo=a.codigo_tipo AND
	ds.nombre IN ('ARQUEO');

SELECT DISTINCT
	foo.fecha,
	foo.numero,
	u.login AS usuario,
	nombre1||' '||apellido1 as usuario,
	foo.ndocumento
FROM
	usuarios u,
	info_documento i,
	general g,
	(SELECT	
		d2.fecha,
		d2.codigo_tipo||'-'||d2.numero::int AS numero,
		d2.ndocumento
	FROM
		documentos d,
		documentos d2,
		args_arqueo_medios a,
		datos_arqueo da,
		datos_arqueo da2,
		tipo_docs td
	WHERE
		d.codigo_tipo=a.codigo_tipo AND
		d.numero=LPAD(a.numero,10,'0') AND
		d.ndocumento=da.narqueo AND
		da.ndocumento = da2.ndocumento AND
		da2.narqueo = d2.ndocumento AND
		d2.codigo_tipo = td.codigo_tipo) AS foo
WHERE
	foo.ndocumento = i.ndocumento AND
	i.id_usuario = u.id_usuario AND
	g.id = u.id_usuario
ORDER BY
	foo.fecha,
	foo.numero;