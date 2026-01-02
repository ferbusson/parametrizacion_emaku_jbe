DROP TABLE IF EXISTS args_attachment;
CREATE TEMP TABLE args_attachment AS
SELECT
	'?'::bigint AS ndocumento;
	
	
SELECT
	'/home/emaku/ElectronicDocuments/'||c.file,
	true as attachment
FROM
	cufe_documentos c,
	args_attachment a
WHERE
	a.ndocumento=c.ndocumento
UNION
SELECT
	REPLACE('/home/emaku/saveDocuments/'||substring(c.file,0,length(c.file)-position('/' in reverse(c.file))+2)||d.codigo_tipo||(d.numero::BIGINT)||'.pdf','ReturnInvoice','Invoice'),
	false as attachment
FROM
	documentos d,
	cufe_documentos c,
	args_attachment a
WHERE
	d.ndocumento=c.ndocumento AND
	a.ndocumento=c.ndocumento;