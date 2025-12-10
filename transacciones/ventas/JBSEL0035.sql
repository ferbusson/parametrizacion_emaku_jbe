--JBSEL0035

select
    ds.codigo_tipo,
    case when dst.nombre = 'MOSTRADOR' THEN 'PEDIDO' ELSE dst.nombre end as nombre
FROM
    documentos_sucursales ds
inner JOIN
    documentos_standar dst
ON
    ds.id_documento = dst.id_documento
WHERE    
    dst.nombre IN ('COTIZACION','MOSTRADOR')
order by
    dst.nombre;