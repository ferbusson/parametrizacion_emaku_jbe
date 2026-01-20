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
	
DROP TABLE IF EXISTS aux_medios;
CREATE TEMP TABLE aux_medios AS
SELECT
	rf.prefijo,
	d.*
FROM
	documentos d,
	tipo_docs t,
	resolucion_facturacion rf,
	resolucion_documento rd,
	arqueos_diarios a
WHERE
	rd.ndocumento=d.ndocumento AND
	rd.id_resolucion_facturacion=rf.id_resolucion_facturacion AND
	t.codigo_tipo=d.codigo_tipo AND
	a.ndocumento=d.ndocumento;

DROP TABLE IF EXISTS aux_f;
CREATE TEMP TABLE aux_f AS
SELECT
	prefijo fprefijo,
	min(numero) AS fdesde,
	max(numero) as fhasta,
	count(1) as fdocs
FROM
	aux_medios 
WHERE
	codigo_tipo like 'F%' AND
	codigo_tipo != 'FW'
GROUP BY
	prefijo;


DROP TABLE IF EXISTS aux_g;
CREATE TEMP TABLE aux_g AS
SELECT
	prefijo AS gprefijo,
	min(numero) AS gdesde,
	max(numero) as ghasta,
	count(1) AS gdocs
FROM
	aux_medios 
WHERE
	codigo_tipo like 'G%' OR
	codigo_tipo = 'FW'
GROUP BY
	prefijo;

DROP TABLE IF EXISTS aux_c;
CREATE TEMP TABLE aux_c AS
SELECT
	prefijo AS cprefijo,
	min(numero) AS cdesde,
	max(numero) as chasta,
	count(1) AS cdocs
FROM
	aux_medios 
WHERE
	codigo_tipo like 'C%'
GROUP BY
	prefijo;

DROP TABLE IF EXISTS aux_z;
CREATE TEMP TABLE aux_z AS
SELECT
	prefijo AS zprefijo,
	min(numero) AS zdesde,
	max(numero) as zhasta,
	count(1) AS zdocs
FROM
	aux_medios 
WHERE
	codigo_tipo like 'Z%'
GROUP BY
	prefijo;

DROP TABLE IF EXISTS aux_u;
CREATE TEMP TABLE aux_u AS
SELECT
	prefijo AS uprefijo,
	min(numero) AS udesde,
	max(numero) as uhasta,
	count(1) AS udocs
FROM
	aux_medios 
WHERE
	codigo_tipo like 'U%'
GROUP BY
	prefijo;

DROP TABLE IF EXISTS aux_p;
CREATE TEMP TABLE aux_p AS
SELECT
	prefijo AS pprefijo,
	min(numero) AS pdesde,
	max(numero) as phasta,
	count(1) AS pdocs
FROM
	aux_medios 
WHERE
	codigo_tipo like 'P%'
GROUP BY
	prefijo;


SELECT
	COALESCE(fprefijo||'-'||fdesde::BIGINT,'-') AS fdesde,
	COALESCE(fprefijo||'-'||fhasta::BIGINT,'-') AS fhasta,
	COALESCE(fdocs,0) AS fdocs,
	COALESCE(cprefijo||'-'||cdesde::BIGINT,'-') AS cdesde,
	COALESCE(cprefijo||'-'||chasta::BIGINT,'-') AS chasta,
	COALESCE(cdocs,0) AS cdocs,
	COALESCE(gprefijo||'-'||gdesde::BIGINT,'-') AS gdesde,
	COALESCE(gprefijo||'-'||ghasta::BIGINT,'-') AS ghasta,
	COALESCE(gdocs,0) AS gdocs,
	COALESCE(zprefijo||'-'||zdesde::BIGINT,'-') AS zdesde,
	COALESCE(zprefijo||'-'||zhasta::BIGINT,'-') AS zhasta,
	COALESCE(zdocs,0) AS zdocs,
	COALESCE(uprefijo||'-'||udesde::BIGINT,'-') AS udesde,
	COALESCE(uprefijo||'-'||uhasta::BIGINT,'-') AS uhasta,
	COALESCE(udocs,0) AS udocs,
	COALESCE(pprefijo||'-'||pdesde::BIGINT,'-') AS pdesde,
	COALESCE(pprefijo||'-'||phasta::BIGINT,'-') AS phasta,
	COALESCE(pdocs,0) AS pdocs
FROM
	aux_f
FULL OUTER JOIN
	aux_g
ON
	TRUE
FULL OUTER JOIN
	aux_c
ON 	
	TRUE
FULL OUTER JOIN
	aux_z
ON 	
	TRUE
FULL OUTER JOIN
	aux_u
ON 	
	TRUE
FULL OUTER JOIN
	aux_p
ON 	
	TRUE;