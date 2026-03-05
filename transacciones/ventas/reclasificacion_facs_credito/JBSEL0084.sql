-- JBSEL0084
select
    rf.tipo_doc,
    trim(rf.prefijo||' - '||td.descripcion) as descripcion
from
    resolucion_facturacion rf,
    tipo_documento td
where
    rf.tipo_doc = td.codigo_tipo
    and rf.tipo_doc like 'G%'
order by
    rf.prefijo;
