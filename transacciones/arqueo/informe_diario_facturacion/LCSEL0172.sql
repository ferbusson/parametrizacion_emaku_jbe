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
	ds.nombre IN ('FACTURACION','FCREDITO','CAMBIOS','FELECTRONICAPOS','FCONTINGENCIA','FCONTINGENCIAE');

DROP TABLE IF EXISTS arqueos_diarios;
CREATE TEMP TABLE arqueos_diarios AS
SELECT
	da.ndocumento
FROM
	documentos d,
	args_arqueo_medios a,
	datos_arqueo da
WHERE
	d.codigo_tipo=a.codigo_tipo AND
	d.numero=LPAD(a.numero,10,'0') AND
	d.ndocumento=da.narqueo;


SELECT
 	COALESCE(e.host,r.ip) AS host,
 	u.login,
 	COALESCE(e.ubicacion,'NA') AS ubicacion,
 	COALESCE(e.serial,'NA') AS serial,
	count(1),
	sum(dd.valor) AS valor
FROM
	datos_documento dd,
	info_documento i,
	usuarios u,
	documentos d,
	arqueos_diarios a,
	tipo_docs t,
	registro_modificacion r
LEFT OUTER JOIN
	equipos_registrados e
ON
	e.ip=r.ip
WHERE
	a.ndocumento=d.ndocumento AND
	d.codigo_tipo=t.codigo_tipo AND
	d.ndocumento=dd.ndocumento AND
 	d.ndocumento=i.ndocumento AND
	i.id_usuario=u.id_usuario AND
 	d.ndocumento=r.ndocumento AND
 	r.id_tipo_modificacion=0
GROUP BY
	COALESCE(e.host,r.ip),
	u.login,
	e.ubicacion,
	e.serial
ORDER BY
	COALESCE(e.host,r.ip),
	u.login;