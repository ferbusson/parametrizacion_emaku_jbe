--JBSEL0037

select
    (d.fecha::date + interval '1 day' * coalesce(i.vencimiento,0))::date as vigencia_actual
FROM
    documentos d
inner JOIN
    info_documento i
ON
    d.ndocumento = i.ndocumento
WHERE
    d.codigo_tipo = '?'
    AND d.numero = lpad('?',10,'0');