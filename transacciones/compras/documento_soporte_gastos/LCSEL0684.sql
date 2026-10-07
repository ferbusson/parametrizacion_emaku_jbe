SELECT
    tc.nombre,
    t.valor
FROM
    tarjetas t,
    tcredito tc,
    documentos d
WHERE
    tc.id_tcredito=t.id_tcredito AND
    d.ndocumento=t.ndocumento AND
    d.codigo_tipo='?' AND 
    d.numero = LPAD('?',10,'0');