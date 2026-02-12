--JBSEL0071
SELECT 
	c.char_cta,
	c.concepto,
	c.debito,
	c.credito
FROM
	contabilizacion_manual_documentos c
inner join
    documentos d
ON  
    d.ndocumento = c.ndocumento
where
    d.codigo_tipo = '?'
    and d.numero = lpad('?',10,'0') -- numero documento
order by
	c.orden;