SELECT DISTINCT
  t.codigo_tipo,
  t.codigo_tipo||'-'||CASE WHEN t.codigo_tipo = 'U9' THEN 'TEMPORAL ARREGLO FACTURAS' ELSE t.descripcion END AS descripcion
FROM 
  tipo_documento t,
  documentos_sucursales ds,
  documentos_sucursales ds2,
  documentos_standar dst  
WHERE 
  t.codigo_tipo = ds.codigo_tipo AND
  ds.id_documento = dst.id_documento AND
  dst.nombre IN ('COTIZACION') AND
  ds2.codigo_tipo = '?' AND
  ds2.id_administracion_sucursales = ds.id_administracion_sucursales;