SELECT
    cu.id_cta,
	cu.char_cta
FROM 
	perfil_cta pc,
	cuentas cu
WHERE 
	cu.id_cta = pc.id_cta and
	cu.tipo = FALSE AND
        (char_cta like '1110%' OR --char_cta = '11052002' 
        char_cta like '1105%' or 
        --char_cta = '11052502' or 
        char_cta = '28050503' or 
        char_cta = '28050504' or char_cta LIKE '1120%' OR
        char_cta LIKE '210520%') 
ORDER BY
        cu.char_cta;