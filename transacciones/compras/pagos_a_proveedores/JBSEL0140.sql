--JBSEL0140
SELECT
	c.char_cta,
	c.nombre,
	d.codigo_tipo || '-' || d.numero::BIGINT ||
            CASE 
                WHEN i.ex_documento IS NOT NULL 
                     AND btrim(i.ex_documento) <> '' 
                THEN '|' || i.ex_documento 
                ELSE '' 
            END as factura,
	la.debe AS debito,
	la.haber AS credito,
	NEXTVAL('tagdata') AS tag,
	cc.codigo as centrocosto
FROM
	cuentas c,
	documentos d,
	info_documento i,
	libro_auxiliar la,
	centrocosto cc	
where
    d.codigo_tipo = '?' and
	d.numero = lpad('?',10,'0') and
	d.ndocumento = i.ndocumento and
	d.ndocumento = la.ndocumento and
	la.id_centrocosto = cc.id_centrocosto and
	la.id_cta = c.id_cta and
	substring(c.char_cta,1,1) in ('2','4') 
ORDER BY
	char_cta;