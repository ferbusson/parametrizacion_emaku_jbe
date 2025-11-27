--Comentarios para descartar argumentos ?,?,?
DROP TABLE IF EXISTS pventaok;
CREATE TABLE pventaok AS
SELECT
	p.id_prod_serv,
	ROUND(CAST((np.pcosto-(np.pcosto*descuento/100))/(1-(cast(m.porcentaje as float)/100))+((np.pcosto-(np.pcosto*descuento/100))/(1-(cast(m.porcentaje as float)/100))*(p.iva/100)) AS numeric),-2) AS pventa1, 
	ROUND(CAST((np.pcosto-(np.pcosto*descuento/100))/(1-(cast(m.porcentaje2 as float)/100))+((np.pcosto-(np.pcosto*descuento/100))/(1-(cast(m.porcentaje2 as float)/100))*(p.iva/100)) AS numeric),-2) AS pventa2
FROM 
	npventa np,
	marcas m,
	item i,
	prod_serv p
WHERE
	np.id_prod_serv=p.id_prod_serv AND
	p.id_item=i.id_item AND
	i.id_marca=m.id_marca;

UPDATE 
	pventa 
SET 
	pventa=pventa1
FROM
	pventaok pk
WHERE
	pventa.id_prod_serv=pk.id_prod_serv AND
	pventa.id_catalogo=1;

UPDATE 
	pventa 
SET 
	pventa=pventa2
FROM
	pventaok pk
WHERE
	pventa.id_prod_serv=pk.id_prod_serv AND
	pventa.id_catalogo=2;

INSERT INTO pventa
SELECT
	1,
	pk.id_prod_serv,
	pventa1
FROM
	pventaok pk,
	(SELECT
		p.id_prod_serv,
		1
	FROM
		pventaok p
	EXCEPT
	SELECT
		p.id_prod_serv,
		id_catalogo
	FROM
		pventa p
	WHERE
		id_catalogo=1) AS foo
WHERE
	pk.id_prod_serv=foo.id_prod_serv;


INSERT INTO pventa
SELECT
	2,
	pk.id_prod_serv,
	pventa2
FROM
	pventaok pk,
	(SELECT
		p.id_prod_serv,
		2
	FROM
		pventaok p
	EXCEPT
	SELECT
		p.id_prod_serv,
		id_catalogo
	FROM
		pventa p
	WHERE
		id_catalogo=2) AS foo
WHERE
	pk.id_prod_serv=foo.id_prod_serv
