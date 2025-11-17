UPDATE 
    info_documento 
SET 
    rf_documento='?',
    id_vendedor='?',
    vencimiento=COALESCE('?',0),
    id_tercero_referente = (select id from general where id_char = trim('?')),
    ex_documento = trim('?')
WHERE 
	ndocumento='?';