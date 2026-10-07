DROP TABLE IF EXISTS aux_params_dc;
CREATE TEMP TABLE aux_params_dc AS
select
	d.ndocumento,
	d.codigo_tipo,
	d.numero,
	a.bandera
from
	(select
		'?'::CHARACTER(2) AS codigo_tipo,
		LPAD('?',10,'0')::CHARACTER(10) AS numero,
		'?'::BOOLEAN AS bandera) as a
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
	datos_prod dp
WHERE
	--d.estado AND
	--d.codigo_tipo = a.codigo_tipo AND
	--d.numero::BIGINT = a.numero::BIGINT AND
	a.ndocumento = id.rf_documento AND
	id.ndocumento = d2.ndocumento AND
	d2.codigo_tipo = 'DC' AND
	d2.estado AND
	d2.ndocumento = dp.ndocumento
GROUP BY
	dp.id_prod_serv,
	a.ndocumento;

SELECT
	codigo,  
	ref_proveedor,
	item,
	0 AS cant,
	pventa,
	iva,
	descuento1,
	stotal,
	vdescuento,
	neto,
	tiva,
	total,
	id_bodega,
	id_prod_serv,
	unitario,
	tag,
	uneto,
	bodega_entrante,
	cant AS cantea,
	cant_devoluciones_ant,
	0 AS disponibledc
FROM
	(SELECT DISTINCT
		p.codigo,  
		SUBSTRING(i.ref_proveedor,1,8) as ref_proveedor,
		--SUBSTRING(i.nombre||' '||m.descripcion,1,18) as item,
	    i.nombre as item,
		dp.cant,
		dp.pventa,
		dp.iva,
		dp.descuento1,
		0 AS stotal,
		0 AS vdescuento,
		0 AS neto,
		0 AS tiva,
		0 AS total,
		dp.id_bodega,
		p.id_prod_serv,
		iv.valor_ent AS unitario, --pcosto tomado de la ea que le corresponde
		dp.orden AS tag,
		0 AS uneto,
		0 AS bodega_entrante,
		COALESCE(adc.cant_devoluciones_ant,0) AS cant_devoluciones_ant
	FROM
		aux_params_dc a,		
		prod_serv p,		
		item i,
		marcas m,
		proveedor_marca pm,
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
		i.id_marca=m.id_marca AND
		pm.id_marca=m.id_marca AND
		dp.ndocumento=a.ndocumento AND
		p.id_prod_serv=dp.id_prod_serv AND
		--d.codigo_tipo=a.codigo_tipo AND
		--d.numero::BIGINT = a.numero::BIGINT AND
		TRUE = a.bandera) AS foo
ORDER BY 
	tag;