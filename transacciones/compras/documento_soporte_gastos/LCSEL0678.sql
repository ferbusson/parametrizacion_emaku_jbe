SELECT
	CURRENT_DATE AS fecha,
	upper(REPLACE(t.descripcion,'Cuenta','C')) AS tipo,
	UPPER(b.nombre)||' - No.'||c.cuenta AS cuenta,
	0.0 AS valor,
	c.id_cuenta_bancaria,
	c.id,
	cu.id_cta,
	CASE WHEN pc.edocumento THEN 'TRUE' ELSE 'FALSE' END AS edocumento,
	CASE WHEN pc.centro THEN 1 ELSE 0 END AS cc,
	CASE WHEN pc.scentro THEN 1 ELSE 0 END AS scc,
	NEXTVAL('tagdata') AS tag,
	cu.char_cta
FROM 
	bancos b,
	(SELECT DISTINCT ON(c.id)
        c.*
    FROM
        cuentas_bancarias c  
    ORDER BY
        c.id DESC,
        c.id_cuenta_bancaria DESC) c,
	perfil_cta pc,
	cuentas cu,
	tipo_cuenta_bancaria t,
	general g
WHERE 
	c.tipo=t.tipo AND
	b.banco=c.banco AND
	cu.char_cta = '11050502' AND
	cu.id_cta = pc.id_cta AND
	c.id=g.id AND
	g.id_char = '?'
ORDER BY
	c.id_cuenta_bancaria;