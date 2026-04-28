--JBUPD0013
UPDATE
	pventa
SET
	pventa = u.pventa1
FROM
	aux_actualizacion_precios_masiva u,
	prod_serv ps
WHERE
	trim(u.codigo) = trim(ps.codigo) and
	trim(u.codigo) != '0' and
	pventa.id_prod_serv = ps.id_prod_serv AND
	pventa.id_catalogo = 1 and
	pventa.id_lista = 1;

UPDATE
	pventa
SET
	pventa = u.pventa2
FROM
	aux_actualizacion_precios_masiva u,
	prod_serv ps
WHERE
	trim(u.codigo) = trim(ps.codigo) and
	trim(u.codigo) != '0' and
	pventa.id_prod_serv = ps.id_prod_serv AND
	pventa.id_catalogo = 2 and
	pventa.id_lista = 1;

UPDATE
	pventa
SET
	pventa = u.pventa3
FROM
	aux_actualizacion_precios_masiva u,
	prod_serv ps
WHERE
	trim(u.codigo) = trim(ps.codigo) and
	trim(u.codigo) != '0' and
	pventa.id_prod_serv = ps.id_prod_serv AND
	pventa.id_catalogo = 3 and
	pventa.id_lista = 1;


-- actualizacion por codigo SAP ------------------------------------------------------------------

UPDATE
	pventa
SET
	pventa = u.pventa1
FROM
	aux_actualizacion_precios_masiva u,
	prod_serv ps
WHERE
	trim(u.sap) = trim(ps.codigo_b) and
	trim(u.codigo) = '0' and
	pventa.id_prod_serv = ps.id_prod_serv AND
	pventa.id_catalogo = 1 and
	pventa.id_lista = 1;

UPDATE
	pventa
SET
	pventa = u.pventa2
FROM
	aux_actualizacion_precios_masiva u,
	prod_serv ps
WHERE
	trim(u.sap) = trim(ps.codigo_b) and
	trim(u.codigo) = '0' and
	pventa.id_prod_serv = ps.id_prod_serv AND
	pventa.id_catalogo = 2 and
	pventa.id_lista = 1;

UPDATE
	pventa
SET
	pventa = u.pventa3
FROM
	aux_actualizacion_precios_masiva u,
	prod_serv ps
WHERE
	trim(u.sap) = trim(ps.codigo_b) and
	trim(u.codigo) = '0' and
	pventa.id_prod_serv = ps.id_prod_serv AND
	pventa.id_catalogo = 3 and
	pventa.id_lista = 1;
