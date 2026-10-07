--JBSEL0128
SELECT
	dp.id_prod_serv,
	dp.iva,
	dp.ndocumento
FROM
	datos_prod dp,
	documentos d
WHERE 	
	d.ndocumento=dp.ndocumento AND 
	d.codigo_tipo='?' and 
	d.numero=LPAD('?',10,'0')
limit 1;