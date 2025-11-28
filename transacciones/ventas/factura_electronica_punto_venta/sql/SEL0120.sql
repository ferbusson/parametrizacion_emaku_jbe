SELECT 
    TRIM(observacion) AS observacion
FROM 
    obs_documento od , 
    documentos d 
WHERE 
    od.ndocumento=d.ndocumento AND
    codigo_tipo='?' AND
    d.numero=LPAD('?',10,'0');