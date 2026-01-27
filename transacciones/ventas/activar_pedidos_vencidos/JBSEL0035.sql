--JBSEL0035

select
    ds.codigo_tipo,
    case when dst.nombre = 'PEDIDOS' THEN 'PEDIDO '||ads.nombre ELSE dst.nombre||' '||ads.nombre end as nombre
FROM
    documentos_sucursales ds
inner JOIN
    documentos_standar dst
ON
    ds.id_documento = dst.id_documento
inner join
    administracion_sucursales ads
ON
    ds.id_administracion_sucursales = ads.id_administracion_sucursales
WHERE    
    dst.nombre IN ('COTIZACION','PEDIDOS')
order by
    dst.nombre;