SELECT
        CASE WHEN c.char_cta LIKE '111%' THEN 'CTE - ' WHEN c.char_cta LIKE '112%' THEN 'AHO - ' END ||UPPER(c.nombre)||' '||c.char_cta AS nombre,
        t.fecha,
        valor
FROM
        transferencias t,
        cuentas c,
        documentos d
WHERE
        t.id_cta=c.id_cta AND
		d.ndocumento=t.ndocumento AND
        d.codigo_tipo='?' AND
        d.numero=LPAD('?',10,'0');