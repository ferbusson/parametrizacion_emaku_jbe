DROP TABLE IF EXISTS args_arqueo;
CREATE TEMP TABLE args_arqueo AS
SELECT
	d.codigo_tipo,
	f.narqueo,
	u.id_usuario,
	f.id_centrocosto
FROM
	documentos d,
	usuarios u,
	(SELECT
		'?'::BIGINT AS narqueo,
		'?'::VARCHAR(70) AS login,
		'?'::SMALLINT AS id_centrocosto) AS f
WHERE
	u.login=f.login AND
	d.ndocumento=f.narqueo;

DROP TABLE IF EXISTS codigo_tipo_arqueos;
CREATE TEMP TABLE codigo_tipo_arqueos as
SELECT DISTINCT
	td.codigo_tipo
from 
	tipo_documento td
where 
	codigo_tipo like 'Q%';


DROP TABLE IF EXISTS codigo_tipo_documentos_sucursal_usuario;
CREATE TEMP TABLE codigo_tipo_documentos_sucursal_usuario AS
SELECT DISTINCT
	ds.codigo_tipo
FROM
	args_arqueo a,
	documentos_standar dst,
	documentos_sucursales ds,
	administracion_sucursales asu
WHERE
	asu.id_centrocosto = a.id_centrocosto AND
	asu.id_administracion_sucursales = ds.id_administracion_sucursales AND
	ds.id_documento = dst.id_documento;

--

INSERT INTO 
	datos_arqueo(
			narqueo,
			ndocumento,
			valor
			) 
SELECT
	a.narqueo,
        d.ndocumento,
        COALESCE(dd.valor,0) AS valor
FROM
	args_arqueo a,		
        documentos d, 
        datos_documento dd, 
        info_documento i,
	(SELECT
		d.ndocumento
	FROM
		documentos d,
	 	codigo_tipo_documentos_sucursal_usuario ctu,
		info_documento i,
		args_arqueo a
	WHERE
	 	d.codigo_tipo = ctu.codigo_tipo AND
		d.ndocumento=i.ndocumento AND
		i.id_usuario=a.id_usuario AND
		d.estado
	EXCEPT
	SELECT
		da.ndocumento
	FROM
		datos_arqueo da,
		documentos d,
		info_documento i,
		args_arqueo a,
		codigo_tipo_arqueos cta
	WHERE
		d.codigo_tipo=cta.codigo_tipo AND
		da.narqueo=d.ndocumento and
		da.narqueo = i.ndocumento and 
		i.id_usuario=a.id_usuario AND
		d.estado) AS foo
WHERE
        d.ndocumento=dd.ndocumento AND
        d.ndocumento=i.ndocumento AND
        d.estado AND
		d.codigo_tipo !=a.codigo_tipo AND
        i.id_usuario=a.id_usuario AND
        d.ndocumento=foo.ndocumento;


