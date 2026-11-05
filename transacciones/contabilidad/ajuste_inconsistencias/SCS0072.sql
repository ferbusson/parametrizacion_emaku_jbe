SELECT
	orden,
	debe,
	haber
FROM
	libro_auxiliar
WHERE
	id_cta='?' AND
	COALESCE(id_tercero,-1) ='?' AND
	COALESCE(id_prod_serv,-1)='?'
ORDER BY
	fecha,
	orden