--JBSEL0087
SELECT
	TRIM(l.descripcion) AS linea,
	TRIM(g.descripcion) AS grupo,
	TRIM(sg.descripcion) AS subgrupo,
	TRIM(ma.descripcion) AS marca,
	trim(sma.descripcion) AS submarca,
	TRIM(ps.codigo) AS codigo,
	TRIM(i.ref_proveedor) AS ref_proveedor,
	TRIM(i.nombre) AS nombre,
	ps.iva,
	ag.descripcion AS tipo_asiento_generico,
	ps.pcosto as costo,
	m.pventa1,
	m.pventa2,
	m.pventa3,
	1::smallint as contador
FROM
	prod_serv ps,
	asientos_genericos ag,
	aux_actualizacion_precios_masiva m,
	item i
inner join
	linea l
on
	i.id_linea = l.id_linea
inner join
	grupo g
on
	i.id_grupo = g.id_grupo
inner join
	sgrupo sg
on
	i.id_sgrupo = sg.id_sgrupo
inner join
	marcas ma
on
	i.id_marca = ma.id_marca
left join
	submarcas sma
on
	i.id_submarca = sma.id_submarca
WHERE
	(
		(TRIM(ps.codigo_b) = TRIM(m.sap) and
		TRIM(m.codigo) = '0')
	) and
	ps.id_asiento_generico = ag.id_asiento_generico and
	ps.id_item = i.id_item
union all
SELECT
	TRIM(l.descripcion) AS linea,
	TRIM(g.descripcion) AS grupo,
	TRIM(sg.descripcion) AS subgrupo,
	TRIM(ma.descripcion) AS marca,
	trim(sma.descripcion) AS submarca,
	TRIM(ps.codigo) AS codigo,
	TRIM(i.ref_proveedor) AS ref_proveedor,
	TRIM(i.nombre) AS nombre,
	ps.iva,
	ag.descripcion AS tipo_asiento_generico,
	ps.pcosto as costo,
	m.pventa1,
	m.pventa2,
	m.pventa3,
	1::smallint as contador
FROM
	prod_serv ps,
	asientos_genericos ag,
	aux_actualizacion_precios_masiva m,
	item i
inner join
	linea l
on
	i.id_linea = l.id_linea
inner join
	grupo g
on
	i.id_grupo = g.id_grupo
inner join
	sgrupo sg
on
	i.id_sgrupo = sg.id_sgrupo
inner join
	marcas ma
on
	i.id_marca = ma.id_marca
left join
	submarcas sma
on
	i.id_submarca = sma.id_submarca
WHERE
	(
		(TRIM(ps.codigo) = TRIM(m.codigo) and
		TRIM(m.codigo) != '0') 
	) and
	ps.id_asiento_generico = ag.id_asiento_generico and
	ps.id_item = i.id_item
ORDER BY
	linea,
	grupo,
	subgrupo,
	marca,
	submarca,
	nombre;