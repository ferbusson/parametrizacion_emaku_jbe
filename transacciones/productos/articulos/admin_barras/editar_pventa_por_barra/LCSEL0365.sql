DROP TABLE IF EXISTS aux_producto_consultar;
CREATE TEMP TABLE aux_producto_consultar AS
SELECT
    ps.id_prod_serv,
    i.id_item,
    ps.codigo
FROM
    prod_serv ps,
    item i
WHERE
    ps.id_item = i.id_item AND
    ps.codigo = '?';
--

DROP TABLE IF EXISTS aux_costo_promedio_producto;
CREATE TEMP TABLE aux_costo_promedio_producto AS
SELECT DISTINCT ON(i.id_prod_serv)
    i.id_bodega,
    i.id_prod_serv,
    i.pinventario
FROM
    inventarios i,
    documentos d,
    aux_producto_consultar lp
WHERE
    i.ndocumento = d.ndocumento AND
    d.estado AND
    lp.id_prod_serv = i.id_prod_serv AND
    i.id_bodega IN (916,920) -- Se acuerda que para estos formularios: editar productos (completo y sencillo) y maestro de productos en la principal el promedio sea el de bodega o americas
ORDER BY
    i.id_prod_serv,
    i.fecha DESC;

--
DROP TABLE IF EXISTS aux_pinventario_ultima_entrada_productos;
CREATE TEMP TABLE aux_pinventario_ultima_entrada_productos AS
SELECT DISTINCT ON(i.id_prod_serv)
    i.id_prod_serv,
    i.valor_ent AS pinventario
FROM
    documentos d,
    inventarios i,
    aux_producto_consultar lp
WHERE
    d.ndocumento = i.ndocumento AND
    d.estado AND
    d.codigo_tipo IN ('EA','RC','IM','AT','IP') AND
    lp.id_prod_serv = i.id_prod_serv
ORDER BY
    i.id_prod_serv,
    i.fecha DESC;
    
--

DROP TABLE IF EXISTS aux_pinventario_productos_bonificados;
CREATE TEMP TABLE aux_pinventario_productos_bonificados AS
SELECT DISTINCT ON(i.id_prod_serv)
    i.id_prod_serv,
    i.valor_ent AS pinventario
FROM
    documentos d,
    inventarios i,
    aux_pinventario_ultima_entrada_productos apb
WHERE
    d.ndocumento = i.ndocumento AND
    d.estado AND
    d.codigo_tipo IN ('EA','RC','IM','AT','IP') AND
    apb.id_prod_serv = i.id_prod_serv AND
    apb.pinventario = 0 AND
    i.valor_ent > 0
ORDER BY
    i.id_prod_serv,
    i.fecha DESC;
--

DROP TABLE IF EXISTS aux_productos_encontrados; -- al buscar la clasificacion de linea grupo subgrupo etc... se encuentra mas de un producto porque crean codigos errados por eso debo poner esta tabla
CREATE TEMP TABLE aux_productos_encontrados AS
SELECT
	i.nombre AS descripcion,
	--ps.pcosto, --se comenta 02 oct 2022 para poner el valor promedio de inventario
    CASE WHEN ROUND(acpp.pinventario::NUMERIC,2) > 0 THEN ROUND(acpp.pinventario::NUMERIC,2) ELSE CASE WHEN ps.pcosto > 0 THEN ROUND(ps.pcosto::NUMERIC,2) ELSE 0 END END AS pcosto,
	COALESCE(pv.pventa,0) AS pventa3,
	l.descripcion AS linea,
	g.descripcion AS grupo,
	sg.descripcion AS sgrupo,
	m.descripcion AS marca,
	COALESCE(sm.descripcion,'NA') AS submarca,
	p.descripcion AS presentacion,
	a.descripcion AS asiento,
	ps.id_prod_serv,    
    CASE WHEN ROUND(aue.pinventario::NUMERIC,2) != 0 THEN ROUND(aue.pinventario::NUMERIC,2) ELSE CASE WHEN ROUND(apb.pinventario::NUMERIC,2) != 0 THEN ROUND(apb.pinventario::NUMERIC,2) ELSE CASE WHEN ps.pcosto > 0 THEN ROUND(ps.pcosto::NUMERIC,2) ELSE 0 END END END AS pcosto_ult_compra
FROM
    aux_producto_consultar aux,
	item i
LEFT OUTER JOIN
	linea l
ON
	i.id_linea = l.id_linea
LEFT OUTER JOIN
	grupo g
ON
	i.id_grupo = g.id_grupo
LEFT OUTER JOIN
	sgrupo sg
ON
	i.id_sgrupo = sg.id_sgrupo
LEFT OUTER JOIN
	marcas m
ON
	i.id_marca = m.id_marca 
LEFT OUTER JOIN
	submarcas sm
ON
	i.id_submarca = sm.id_submarca
LEFT OUTER JOIN
	presentacion p
ON
	i.id_presentacion = p.id_presentacion
LEFT OUTER JOIN
	prod_serv ps
ON
	ps.id_item = i.id_item
LEFT OUTER JOIN
	pventa pv
ON
	ps.id_prod_serv = pv.id_prod_serv AND
	pv.id_catalogo = 3 AND
    pv.id_lista = 1
LEFT OUTER JOIN	
	asientos_genericos a
ON
	ps.id_asiento_generico = a.id_asiento_generico
LEFT OUTER JOIN
    aux_costo_promedio_producto acpp
ON
    ps.id_prod_serv = acpp.id_prod_serv
LEFT OUTER JOIN
    aux_pinventario_ultima_entrada_productos aue
ON
    ps.id_prod_serv = aue.id_prod_serv
LEFT OUTER JOIN
    aux_pinventario_productos_bonificados apb
ON
    ps.id_prod_serv = apb.id_prod_serv    
WHERE	
	aux.id_item = i.id_item;
    
SELECT
    a.*
FROM
    aux_productos_encontrados a,
    aux_producto_consultar pc
WHERE
    a.id_prod_serv = pc.id_prod_serv;