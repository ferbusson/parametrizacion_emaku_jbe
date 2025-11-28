-- JBSEL0020.sql
-- Total puntos de un tercero asociado a un documento especifico
with aux_tercero_pedidos as ( --obtener el id del tercero asociado al documento
SELECT
    td.id
FROM
    documentos d
inner join
    tercero_def td
on
    d.ndocumento = td.ndocumento    
WHERE
    d.codigo_tipo='?' AND
    d.numero=LPAD('?',10,'0')
limit 1)
-- obtener los puntos del tercero
select
	pt.saldo as puntos
from
	puntos_tercero pt
where 
	pt.id_tercero in (select id from aux_tercero_pedidos)
order by
    pt.fecha desc,
    pt.id_puntos_tercero desc
limit 1;