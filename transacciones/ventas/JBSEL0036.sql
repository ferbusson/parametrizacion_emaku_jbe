--JBSEL0036

select
    d.ndocumento
FROM
    documentos d
WHERE
    d.codigo_tipo = '?'
    AND d.numero = lpad('?',10,'0');