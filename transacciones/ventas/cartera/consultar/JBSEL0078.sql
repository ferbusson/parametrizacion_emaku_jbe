--JBSEL0078

select
    cc.nombre
from
    documentos d
inner join
    libro_auxiliar la
on
    d.ndocumento = la.ndocumento
inner join
    centrocosto cc
on
    la.id_centrocosto = cc.id_centrocosto
where
	la.id_centrocosto is not null
    and d.codigo_tipo = '?'
    and d.numero = lpad('?',10,'0')
limit 1;