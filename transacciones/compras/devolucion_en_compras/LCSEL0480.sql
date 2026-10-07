DROP TABLE IF EXISTS aux_params_dc;
CREATE TEMP TABLE aux_params_dc AS
select
	d.ndocumento,
	d.codigo_tipo,
	d.numero,
	a.codigo
from
	(select
		'?'::CHARACTER(14) AS codigo,
		'?'::CHARACTER(2) AS codigo_tipo,
		LPAD('?',10,'0')::CHARACTER(10) AS numero) as a
join
	documentos d
on
	a.codigo_tipo = d.codigo_tipo and
	a.numero = d.numero
where
	d.estado;

DROP TABLE IF EXISTS aux_pcosto_inventarios;
CREATE TEMP TABLE aux_pcosto_inventarios as
select
	i.ndocumento,
	i.id_prod_serv,
	i.valor_ent
from
	inventarios i
join
	aux_params_dc a
on
	i.entrada is not null
	and a.ndocumento = i.ndocumento;


DROP TABLE IF EXISTS aux_dc_anteriores;
CREATE TEMP TABLE aux_dc_anteriores AS
SELECT
	a.ndocumento, -- ndocumento EA
	dp.id_prod_serv,
	SUM(dp.cant) AS cant_devoluciones_ant
FROM
	aux_params_dc a,
	--documentos d,
	info_documento id,
	documentos d2,
	datos_prod dp,
	prod_serv ps
WHERE
	--d.estado AND
	--d.codigo_tipo = a.codigo_tipo AND
	--d.numero::BIGINT = a.numero::BIGINT AND
	a.ndocumento = id.rf_documento AND
	id.ndocumento = d2.ndocumento AND
	d2.codigo_tipo = 'DC' AND
	d2.estado AND
	d2.ndocumento = dp.ndocumento AND
	dp.id_prod_serv = ps.id_prod_serv AND
	a.codigo = ps.codigo
GROUP BY
	dp.id_prod_serv,
	a.ndocumento;


SELECT
	foo.ref_proveedor,
        CASE WHEN (foo.cant - foo.cant_devoluciones_ant) <= 0 THEN 'SIN SALDO PARA DEVOLUCION' ELSE foo.nombre END AS nombre,
        foo.marca,
        0,
        foo.id_bodega,
        foo.id_prod_serv,
        foo.pventa,
        foo.iva,
        foo.cant,
        foo.descuento1,
        foo.id_bodega AS id_bodegaEntrante,
        cant_devoluciones_ant,
        foo.pcosto
FROM	
	(SELECT
		--SUBSTRING(i.ref_proveedor,1,12) AS ref_proveedor,
	 	i.ref_proveedor,
		--SUBSTRING(i.nombre,1,18) AS nombre,
	 	i.nombre,
		m.descripcion AS marca,
		dp.id_bodega,
		p.id_prod_serv,
		dp.pventa,
		dp.iva,
		dp.cant,
		dp.descuento1,
		COALESCE(adc.cant_devoluciones_ant,0) AS cant_devoluciones_ant,
		iv.valor_ent as pcosto
	FROM
		aux_params_dc a,
		prod_serv p,
		item i,
		marcas m,		
		--documentos d,
		datos_prod dp
	inner join
		aux_pcosto_inventarios iv
	on 
		dp.ndocumento = iv.ndocumento and
		dp.id_prod_serv = iv.id_prod_serv
	LEFT OUTER JOIN
		aux_dc_anteriores AS adc
	ON	
		dp.ndocumento = adc.ndocumento AND
		dp.id_prod_serv = adc.id_prod_serv
	WHERE
		i.id_item=p.id_item AND
		p.id_prod_serv = dp.id_prod_serv AND
		m.id_marca=i.id_marca AND
		a.ndocumento = dp.ndocumento AND
		--d.codigo_tipo=a.codigo_tipo AND
		p.codigo = a.codigo --AND
		--d.numero = a.numero
) AS foo;