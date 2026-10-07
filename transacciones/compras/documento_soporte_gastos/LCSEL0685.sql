SELECT
    CASE WHEN ct.char_cta LIKE '111%' THEN 'CTE - ' WHEN ct.char_cta LIKE '112%' THEN 'AHO - ' END ||UPPER(ct.nombre)||' '||ct.char_cta AS nombre,
    c.fecha,    
    c.numero,
    c.valor
FROM
    cheques c,
    cuentas ct,
    documentos d
WHERE
    c.id_cta=ct.id_cta AND
    d.ndocumento=c.ndocumento AND
    d.codigo_tipo='?' AND
    d.numero=LPAD('?',10,'0');