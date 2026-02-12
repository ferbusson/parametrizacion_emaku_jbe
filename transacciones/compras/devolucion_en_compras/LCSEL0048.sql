SELECT 
    cxp.nombre
FROM 
    datos_documento dd,
    documentos d,
    clase_cxp cxp,
    cuentas cu
WHERE 
    d.ndocumento=dd.ndocumento AND
    dd.id_clase_cxp = cxp.id_clase_cxp AND
    cxp.id_cta_cxp = cu.id_cta AND
    d.codigo_tipo='?' AND
    d.numero=LPAD('?',10,'0');