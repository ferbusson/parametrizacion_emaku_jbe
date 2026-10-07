--JBSEL0132
SELECT
    CASE WHEN ct.char_cta LIKE '111%' THEN 'CTE - ' WHEN ct.char_cta LIKE '112%' THEN 'AHO - ' END ||UPPER(ct.nombre)||' '||ct.char_cta AS nombre,
    t.fecha,    
    t.valor,
    0 as comision,
    0 as valor_comision,
    e.id_tercero_banco,
    '51159525' AS cuenta_gravamen,
    CASE WHEN pc.edocumento THEN 'TRUE' ELSE 'FALSE' END AS edocumento,
	CASE WHEN pc.centro THEN 1 ELSE 0 END AS cc,
	CASE WHEN pc.scentro THEN 1 ELSE 0 END AS scc,
	NEXTVAL('tagdata') AS tag,
	ct.id_cta
FROM
    transferencias t,
    cuentas ct,
    documentos d,
    enlace_bancos e,
	perfil_cta pc
WHERE
    t.id_cta=ct.id_cta and
    ct.id_cta = e.id_cta AND
	ct.id_cta = pc.id_cta AND
    d.ndocumento=t.ndocumento AND
    d.codigo_tipo='?' AND
    d.numero=LPAD('?',10,'0');