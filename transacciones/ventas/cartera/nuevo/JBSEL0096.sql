--JBSEL0096
select
	d.fecha,
    c.dcredito,
    CAST(d.fecha + CAST(c.dcredito || ' days' AS INTERVAL) AS DATE) AS vencimiento,
    d.codigo_tipo||'-'||d.numero::bigint as numero,
    c.abono_comprobante,
    0 as valor_a_usar,           -- Duplicate column as in original
    0 AS col6,       -- Zero columns as in original
    0 AS col7,
    0 AS col8,
    0 AS col9,
    0 AS col10,
    id.ex_documento,
    0 AS col12,
    0 AS col13,
    0 AS col14,
    d.ndocumento,
    0.0 as vfactura,
    0 AS col17,
    cu.char_cta,
    cu.id_cta
FROM 
	cartera c
join
	documentos d 
ON 
	c.ncomprobante = d.ndocumento
JOIN 
	info_documento id 
ON 
	d.ndocumento = id.ndocumento
JOIN 
	cuentas cu 
ON 
	c.id_cta = cu.id_cta
WHERE 
	d.estado = true
	and c.nfactura is null
	and c.id_cta = (select id_cta from cuentas where char_cta = '28050501') --cuenta anticipos
	and c.idtercero = '?'
ORDER BY 
	fecha, 
	numero;