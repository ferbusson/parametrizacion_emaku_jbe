SELECT 
    cu.char_cta
FROM 
    libro_auxiliar l,
    cuentas cu
WHERE 
    l.id_cta = cu.id_cta AND
	cu.char_cta LIKE '1305%' AND
    l.ndocumento='?'
limit 1;