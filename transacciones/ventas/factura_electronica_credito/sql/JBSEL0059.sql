--JBSEL0059
SELECT  
    coalesce(diascredito,0) as diascredito
FROM
    documentos d
inner JOIN
    tercero_def td
ON
    d.ndocumento = td.ndocumento
left join
    info_credito ic
ON  
    td.id = ic.id
WHERE
    d.codigo_tipo = '?'
    and d.numero = lpad('?',10,'0')
limit 1;