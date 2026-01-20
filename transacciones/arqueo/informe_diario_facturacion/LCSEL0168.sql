DROP TABLE IF EXISTS args_arqueo_medios;
CREATE TEMP TABLE args_arqueo_medios AS
SELECT
	'?'::VARCHAR(2) AS codigo_tipo,
	'?'::DATE AS fecha; 

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

DROP TABLE IF EXISTS aux_docs;
CREATE TEMP TABLE aux_docs AS
select
	d.ndocumento
from
	args_arqueo_medios a,
	tipo_docs t,
	documentos d
WHERE
	d.fecha::date = a.fecha and
	d.codigo_tipo = t.codigo_tipo ; -- Solo tipos documento fac, fac credito y cambios

DROP TABLE IF EXISTS arqueo_except;
CREATE TEMP TABLE arqueo_except AS
SELECT distinct
	ad.ndocumento
FROM
	aux_docs ad
EXCEPT
SELECT DISTINCT
	da.ndocumento
FROM
	datos_arqueo da,
	documentos d,
	args_arqueo_medios a
WHERE
	d.codigo_tipo=a.codigo_tipo AND
	da.narqueo=d.ndocumento AND
	d.estado;

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
	arqueo_except ae,
	registro_modificacion r	
LEFT OUTER JOIN
	equipos_registrados e
ON
	e.ip=r.ip
WHERE
	dd.ndocumento=d.ndocumento AND
	d.ndocumento=i.ndocumento and
	d.estado and
	i.id_usuario=u.id_usuario AND
	r.ndocumento=d.ndocumento AND
	r.id_tipo_modificacion=0 AND	
	d.ndocumento = ae.ndocumento
GROUP BY
	COALESCE(e.host,r.ip),	
	u.login,
	e.ubicacion,
	e.serial
ORDER BY
	COALESCE(e.host,r.ip),
	u.login;