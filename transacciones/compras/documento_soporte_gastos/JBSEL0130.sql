--JBSEL0130
SELECT
    tc.nombre,
    t.valor,
    tc.comision,
    t.comision as valor_comision,
    cu.char_cta,
    tc.id_tercero_banco,
    '51159525' as cuenta_gravamen,
    CASE WHEN pc.edocumento THEN 'TRUE' ELSE 'FALSE' END AS edocumento,
	CASE WHEN pc.centro THEN 1 ELSE 0 END AS cc,
	CASE WHEN pc.scentro THEN 1 ELSE 0 END AS scc,
	NEXTVAL('tagdata') AS tag
FROM
    tarjetas t,
    tcredito tc,
    perfil_cta pc,
    cuentas cu,
    documentos d
where
	tc.id_banco = cu.id_cta and
	cu.id_cta = pc.id_cta and
    tc.id_tcredito=t.id_tcredito AND
    d.ndocumento=t.ndocumento AND
    d.codigo_tipo='?' AND 
    d.numero = LPAD('?',10,'0');


