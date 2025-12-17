--JBSEL0046
-- 2 pedido a credito
-- 1 pedido contado

SELECT
    case when i.pedido_a_credito then '2' else '1' end as pedido_a_credito
FROM 
    documentos d
inner join
    info_documento i
    on d.ndocumento = i.ndocumento
WHERE
    d.codigo_tipo = '?'
    AND d.numero = lpad('?',10,'0');