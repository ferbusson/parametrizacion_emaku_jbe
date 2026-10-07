SELECT
    co.fecha,
    upper(REPLACE(t.descripcion,'Cuenta','C')) AS tipo,
    UPPER(b.nombre)||' - No.'||c.cuenta AS cuenta,
    co.valor
FROM
    consignaciones co,
    bancos b,
    (SELECT DISTINCT ON(c.id)
        c.*
    FROM
        cuentas_bancarias c  
    ORDER BY
        c.id DESC,
        c.id_cuenta_bancaria DESC) c,
    tipo_cuenta_bancaria t,
    documentos d
WHERE
    co.id_cuenta_bancaria = c.id_cuenta_bancaria AND
    c.tipo=t.tipo AND
    b.banco=c.banco AND
    d.ndocumento=co.ndocumento AND
    d.codigo_tipo='?' AND 
    d.numero = LPAD('?',10,'0')
   ORDER BY
	co.id_cuenta_bancaria;