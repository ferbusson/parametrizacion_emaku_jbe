--JBSEL0129
SELECT
    co.fecha,
    upper(REPLACE(coalesce(t.descripcion,'--'),'Cuenta','C')) AS tipo,
    UPPER(coalesce(b.nombre,'--'))||' - No.'||coalesce(c.cuenta,'--') AS cuenta,
    co.valor,
    coalesce(co.id_cuenta_bancaria,-1) as id_cuenta_bancaria,
    coalesce(co.id_banco,-1) as id_banco,
    co.id_cta,
    'NULL' AS edocumento,
    0 as sumcc,
    0 as sumscc,
    co.id_cta::VARCHAR||co.ndocumento::VARCHAR as tagdata,
	cu.char_cta
FROM    
    documentos d,
    cuentas cu,
    consignaciones co
left join 
    (SELECT DISTINCT ON(c.id)
        c.*
    FROM
        cuentas_bancarias c  
    ORDER BY
        c.id DESC,
        c.id_cuenta_bancaria DESC) c
on
	co.id_cuenta_bancaria = c.id_cuenta_bancaria
left join
	tipo_cuenta_bancaria t
on
	c.tipo=t.tipo
left join
	bancos b
on
	b.banco=c.banco
WHERE
    co.id_cta = cu.id_cta and    
    d.ndocumento=co.ndocumento AND
    d.codigo_tipo='?' AND 
    d.numero = LPAD('?',10,'0')
   ORDER BY
	co.id_cuenta_bancaria;