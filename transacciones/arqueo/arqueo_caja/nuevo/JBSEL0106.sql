-- CONSULTA DATOS DE RETIROS PARCIALES PARA NUEVO ARQUEO
DROP TABLE IF EXISTS tmp_usuario;
CREATE TEMP TABLE tmp_usuario AS
SELECT '?'::VARCHAR(70) AS login;


SELECT 
	d2.fecha,
	d2.codigo_tipo||'-'||d2.numero::integer AS numero,
	dd.valor 
FROM 
	datos_documento dd,
	documentos d2,
	(SELECT
		d.ndocumento
	FROM
		documentos d,
		info_documento i,
		usuarios u,
		tmp_usuario t,
		documentos_standar s,
		documentos_sucursales ds 
	WHERE
		s.nombre ='RETIRO PARCIAL' AND 
		s.id_documento = ds.id_documento AND 
		d.codigo_tipo = ds.codigo_tipo  AND 
		d.estado AND
		d.ndocumento=i.ndocumento AND
		i.id_usuario=u.id_usuario AND
		u.login=t.login
	EXCEPT
	SELECT
		a.ndocumento
	FROM
		documentos d,
		datos_arqueo a,
		info_documento i,
		usuarios u,
		tmp_usuario t,
		documentos_standar s,
		documentos_sucursales ds 
	WHERE
		s.nombre ='RETIRO PARCIAL' AND 
		s.id_documento = ds.id_documento AND 
		d.codigo_tipo = ds.codigo_tipo  AND 
		d.ndocumento=a.ndocumento AND
		d.estado AND
		A.ndocumento=i.ndocumento AND
		i.id_usuario=u.id_usuario AND
		u.login=t.login) AS foo
WHERE
	foo.ndocumento=dd.ndocumento AND
	d2.ndocumento = dd.ndocumento;