--JBINS0014
DROP TABLE IF EXISTS aux_listado_precios;
CREATE TABLE aux_listado_precios AS
SELECT
        CAST('?' AS int) AS id_asiento_generico,
	CAST('?' AS float8) AS costo,
    trim('?'::text) as barra;
	
INSERT INTO prod_serv(
        id_asiento_generico,
	id_color,
	codigo,
	estado,
	codigo_b,
	descripcion,
	iva,
	pcosto,
	comision,
	id_item,
	id_talla,
        id_tipo_prod_serv)
SELECT
    p.id_asiento_generico, 
	1 AS id_color,
	p.barra,
	TRUE,
	p.barra,
	'',
	a.tarifa,
	p.costo,
	'0',
	CURRVAL('item_id_item_seq'),
	1 AS id_talla,
	'001'
FROM 
	aux_listado_precios p,
	asientos_genericos a
WHERE
	p.id_asiento_generico = a.id_asiento_generico;
