INSERT INTO 
	direcciones(
		id,
		descripcion,
		direccion,
		id_pais,
		id_dep,
		municipio) 
VALUES((SELECT id FROM general WHERE id_char='?'),'PRINCIPAL',UPPER('?'),'170','?','?');