-- MTSEL0730
DROP TABLE IF EXISTS aux_parametros_reporte;
CREATE TEMP TABLE aux_parametros_reporte AS
select 
	fecha,
	substring(id_bodega_ppal,1,position('-' in id_bodega_ppal)-1) as id_bodega_ppal,
	substring(id_bodega_ppal,position('-' in id_bodega_ppal)+1,length(id_bodega_ppal)) as id_administracion_sucursales
from
	(SELECT 
		'?'::VARCHAR AS fecha,
		'?'::VARCHAR AS id_bodega_ppal) as foo;
  
-- validacion que evita error al abrir el formulario
UPDATE
  aux_parametros_reporte
SET
  fecha = '1900-01-01'::DATE,
  id_bodega_ppal = '-1'
WHERE
  TRIM(fecha) = '';

-- Inicia Conexiones remotas
DROP TABLE IF EXISTS remote_cnx;
CREATE TEMP TABLE remote_cnx AS
SELECT
    'CNX'||round((random()*1000000)::numeric,0) AS cnx,
    host,
    dbname,
    usuario,
    clave
FROM
    dblink_sucursales d,
    aux_parametros_reporte a
WHERE
    d.id_bodega = a.id_bodega_ppal::INTEGER AND
  d.host != 'localhost' AND -- evita conexiones con la misma base de datos lacali cuando se recibe id de bodega 138 1252
    d.online;         -- el reporte local no entra por dblink

-- SE ESTABLECE EL LINK CON EL SERVIDOR 
DROP TABLE IF EXISTS cnx_remote;
CREATE TEMP TABLE cnx_remote AS 
SELECT
    (SELECT dblink_connect(cnx,'host='||dl.host||' dbname='||dl.dbname||' user='||dl.usuario||' port=5432 password='||dl.clave||''))
FROM
    remote_cnx AS dl;
  
--Guardar parametros reporte en bd sucursal
DROP TABLE IF EXISTS aux_exec_query;
    CREATE TEMP TABLE aux_exec_query AS 
    SELECT
      (SELECT
        dblink_exec((SELECT cnx FROM remote_cnx),
        '
        DROP TABLE IF EXISTS aux_parametros_reporte_sucursal01;
        CREATE TABLE aux_parametros_reporte_sucursal01 (fecha VARCHAR, id_bodega_ppal VARCHAR);
        '));

DROP TABLE IF EXISTS aux_exec_query;
CREATE TEMP TABLE aux_exec_query AS 
SELECT
  (SELECT
    dblink_exec((SELECT cnx FROM remote_cnx),
      'INSERT INTO aux_parametros_reporte_sucursal01 SELECT '''||foo.fecha||''','''||foo.id_bodega_ppal||''' '))
FROM
  (SELECT
    a.fecha,
    a.id_bodega_ppal
  FROM
    aux_parametros_reporte a) as foo;
    
DROP TABLE IF EXISTS aux_resultado_repo_remoto;
CREATE TEMP TABLE aux_resultado_repo_remoto AS 
SELECT
  _id_char AS id_char,
  _nombre AS nombre,
  _vendedor AS vendedor,
  _total AS total,
  _id_administracion_sucursales AS id_administracion_sucursales
FROM
  dblink((SELECT cnx FROM remote_cnx),'SELECT
  _id_char,
  _nombre,
  _vendedor,
  _total,
  _id_administracion_sucursales
FROM
  ventas_del_dia_gerencia_parte01();') AS rr(_id_char character(14), _nombre character varying(100), _vendedor text, _total double precision, _id_administracion_sucursales integer);

DROP TABLE IF EXISTS cnx_remote;
CREATE TEMP TABLE cnx_remote AS 
SELECT dblink_disconnect(cnx) FROM remote_cnx;

-- Fin Conexiones remotas


DROP TABLE IF EXISTS aux_cuentas_usadas;
CREATE TEMP TABLE aux_cuentas_usadas AS
SELECT DISTINCT
  c.id_cta
FROM
  cuentas c
WHERE
  (c.char_cta like '11%' OR
  c.char_cta like '1305%' OR    
  c.char_cta like '28050502%' OR
  c.char_cta like '28050504%' OR
  c.char_cta like '2810%');

DROP TABLE IF EXISTS aux_prefijos_ventas;
CREATE TEMP TABLE aux_prefijos_ventas AS
SELECT
  ads.id_administracion_sucursales,
  ads.nombre,
  ds.codigo_tipo
FROM
  administracion_sucursales ads,
  documentos_standar dst,
  documentos_sucursales ds,
  aux_parametros_reporte a
WHERE
  CASE WHEN TRIM(a.id_bodega_ppal) = '' THEN TRUE ELSE ads.id_bodega_ppal=a.id_bodega_ppal::INTEGER END and
  CASE WHEN TRIM(a.id_bodega_ppal) = '' THEN TRUE ELSE ads.id_administracion_sucursales=a.id_administracion_sucursales::INTEGER END AND
  ds.id_administracion_sucursales=ads.id_administracion_sucursales AND
  ds.id_documento = dst.id_documento and
  dst.nombre in ('FCREDITO','FACTURACION','CAMBIOS','FCONTINGENCIA','FELECTRONICAPOS','FCONTINGENCIAE');


DROP TABLE IF EXISTS aux_devoluciones;
CREATE TEMP TABLE aux_devoluciones AS
SELECT
  id_char,
  ads.nombre,
  COALESCE(nombre1,'')||' '||COALESCE(apellido1,'')AS vendedor,
  SUM(l.haber) AS total,
  ads.id_administracion_sucursales
FROM
  administracion_sucursales ads,
  documentos_standar dst,
  documentos_sucursales ds,
  documentos d, 
  general g,
  aux_parametros_reporte a,
  libro_auxiliar l, 
  info_documento i,
  cuentas c
WHERE
  CASE WHEN TRIM(a.id_bodega_ppal) = '' THEN TRUE ELSE ads.id_bodega_ppal=a.id_bodega_ppal::INTEGER END and
  CASE WHEN TRIM(a.id_bodega_ppal) = '' THEN TRUE ELSE ads.id_administracion_sucursales=a.id_administracion_sucursales::INTEGER END AND
  ds.id_administracion_sucursales=ads.id_administracion_sucursales AND
  ds.codigo_tipo = d.codigo_tipo AND
  ds.id_documento = dst.id_documento and
  dst.nombre in ('DEVOLUCION VENTA','DVENTA ELECTRONICA') and
        d.ndocumento=l.ndocumento AND
        d.fecha::date = a.fecha::DATE AND
        l.id_cta = c.id_cta AND
  (c.char_cta like '11%' OR
  c.char_cta like '1305%' OR    
  c.char_cta like '28050502%' OR
  c.char_cta like '28050504%' OR
  c.char_cta like '2810%') AND
        d.ndocumento=i.ndocumento AND
        d.estado=true AND
        i.id_usuario = g.id
GROUP BY
  id_char,
  COALESCE(nombre1,'')||' '||COALESCE(apellido1,''),
  ads.id_administracion_sucursales;

DROP TABLE IF EXISTS aux_documentos_ventas_reporte;
CREATE TEMP TABLE aux_documentos_ventas_reporte AS
SELECT
  d.ndocumento,
  ap.nombre,
  i.id_usuario,
  ap.id_administracion_sucursales
FROM
  aux_prefijos_ventas ap,
  documentos d, 
  aux_parametros_reporte a,
  info_documento i
WHERE
  d.fecha::date = a.fecha::DATE AND
  ap.codigo_tipo = d.codigo_tipo AND
  d.ndocumento=i.ndocumento AND
  d.estado=true;


DROP TABLE IF EXISTS aux_suma_documentos_ventas_reporte;
CREATE TEMP TABLE aux_suma_documentos_ventas_reporte AS
SELECT
  a.nombre,
  a.id_administracion_sucursales,
  a.id_usuario,
  SUM(l.debe) AS total
FROM
  aux_documentos_ventas_reporte a,
  libro_auxiliar l,
  aux_cuentas_usadas ac
WHERE
  a.ndocumento = l.ndocumento AND
  l.id_cta = ac.id_cta
GROUP BY
  a.nombre,
  a.id_administracion_sucursales,
  a.id_usuario;

--
DROP TABLE IF EXISTS aux_ventas;
CREATE TEMP TABLE aux_ventas AS
SELECT
  g.id_char,
  a.nombre,
  COALESCE(g.nombre1,'')||' '||COALESCE(g.apellido1,'')AS vendedor,
  a.total,
  a.id_administracion_sucursales
FROM
  aux_suma_documentos_ventas_reporte a,
  general g
WHERE
  a.id_usuario = g.id;


DROP TABLE IF EXISTS aux_resultado_repo_local;
CREATE TEMP TABLE aux_resultado_repo_local AS
SELECT
  COALESCE(a1.id_char,a2.id_char) AS id_char,
  COALESCE(a1.nombre,a2.nombre) AS nombre,
  COALESCE(a1.vendedor,a2.vendedor) AS vendedor,
  COALESCE(a1.total,0) - COALESCE(a2.total,0) AS total,
  COALESCE(a1.id_administracion_sucursales,a2.id_administracion_sucursales) AS id_administracion_sucursales
FROM
  aux_ventas a1
FULL OUTER JOIN
  aux_devoluciones a2
ON
  a1.id_char = a2.id_char AND
  a1.id_administracion_sucursales = a2.id_administracion_sucursales;


SELECT
  id_char,
  nombre,
  vendedor,
  total,
  id_administracion_sucursales
FROM
  aux_resultado_repo_remoto
UNION ALL
SELECT
  id_char,
  nombre,
  vendedor,
  total,
  id_administracion_sucursales
FROM
  aux_resultado_repo_local
ORDER BY
  nombre,
  vendedor;