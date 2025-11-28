SELECT 
 'Documento'||' '||case when estado='t' then 'Habilitado' else 'Anulado' end 
FROM 
 documentos 
WHERE
 codigo_tipo='?' AND numero=lpad('?',10,'0')