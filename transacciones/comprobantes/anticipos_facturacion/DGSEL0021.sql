SELECT 
	CASE WHEN estado then '' else 'Documento Anulado' end 
FROM 
	documentos
WHERE 
	codigo_tipo='?' AND 
	numero=lpad('?',10,'0');