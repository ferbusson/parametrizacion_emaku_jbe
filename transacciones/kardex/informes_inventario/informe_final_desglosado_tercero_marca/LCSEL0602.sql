--LCSEL0602
DROP TABLE IF EXISTS aux_params_reporte;
CREATE TEMP TABLE aux_params_reporte AS
SELECT
    '?'::TIMESTAMP AS fecha_corte,
    '?'::INTEGER AS id_bodega,
    '?'::VARCHAR(25) AS id_char,
    '?'::VARCHAR(10) AS id_marca,
    '?'::SMALLINT AS bandera_saldo; -- -1: TODOS, 0: saldo 0, 1: con saldo
/*
138 | P-PRINCIPAL
241 | P-CARRERA21
243 | P-CCARPINTE
245 | P-AMERICAS  
*/


DROP TABLE IF EXISTS aux_marcas_y_proveedores;
CREATE TEMP TABLE aux_marcas_y_proveedores AS
select
	m.id_marca,
	m.descripcion,
	-- Cambiamos string_agg por array_agg
	array_agg(coalesce(g.id_char, '--')) as nitcc_proveedor_array,
	string_agg(TRIM(COALESCE(g.nombre1,'--')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.razon_social,'')),' | ') as proveedor
from
	marcas m
left join
	proveedor_marca pm on m.id_marca = pm.id_marca
left join
	general g on pm.id_proveedor = g.id
group by
	m.id_marca,
	m.descripcion
order by
	m.id_marca;
    

/* de aqui en adelante inicia reporte en local */

DROP TABLE IF EXISTS aux_listado_productos;
CREATE TEMP TABLE aux_listado_productos AS
SELECT
    iv.id_bodega,
    g2.nombre1 AS nombre_bodega,
    p.id_prod_serv,
    array_to_string(m.nitcc_proveedor_array,chr(10)) AS nitcc_proveedor,
    m.proveedor,
    m.descripcion AS marca,
    COALESCE(sm.descripcion,'') AS submarca,
    l.descripcion AS linea,
    gr.descripcion AS grupo,
    sg.descripcion AS subgrupo,
    p.codigo,
    CASE WHEN p.estado THEN 'Activo' ELSE 'Inactivo' END AS estado,
    p.pcosto,
    i.ref_proveedor AS referencia,
    i.nombre AS descripcion,
    sum(COALESCE(iv.entrada,0)) AS entrada,
    sum(COALESCE(iv.salida,0)) AS salida
FROM
    general b,
    aux_marcas_y_proveedores m,
    linea l,
    aux_params_reporte a,
    grupo gr,
    sgrupo sg,
    prod_serv p,
    inventarios iv,        
    general g2,
    item i
LEFT OUTER JOIN
    submarcas sm
ON
    i.id_submarca = sm.id_submarca
WHERE
    i.id_linea = l.id_linea AND
    i.id_grupo = gr.id_grupo AND
    i.id_sgrupo = sg.id_sgrupo and
    i.id_marca = m.id_marca and
    --g.id = pm.id_proveedor AND
    b.id=iv.id_bodega AND    
    --p.codigo = '440288' and
    --p.id_prod_serv = 12823 and
    p.id_item=i.id_item AND
    iv.id_prod_serv=p.id_prod_serv AND
    CAST(iv.fecha as timestamp) <= a.fecha_corte AND
    iv.id_bodega = a.id_bodega AND
    a.id_bodega NOT IN (912,913,914,915,918,919) and --bodegas remotas en la cali
    CASE WHEN TRIM(a.id_char) = '' THEN TRUE ELSE a.id_char = any(nitcc_proveedor_array) END AND
    CASE WHEN TRIM(a.id_marca) = '' THEN TRUE ELSE m.id_marca::VARCHAR = a.id_marca END AND
    iv.id_bodega = g2.id
GROUP BY
    iv.id_bodega,
    g2.nombre1, --nombre bodega
    p.id_prod_serv,
    m.nitcc_proveedor_array, -- id_char proveedor
    m.proveedor, --nombre proveedor
    m.descripcion, --marca
    COALESCE(sm.descripcion,''), --submarca
    l.descripcion, -- linea
    gr.descripcion, -- grupo
    sg.descripcion, -- subgrupo
    p.codigo,
    CASE WHEN p.estado THEN 'Activo' ELSE 'Inactivo' END,
    p.pcosto,
    i.ref_proveedor,
    i.nombre;

--
/*
select
	i.id_bodega,
	i.id_prod_serv--,
	--sum(coalesce(i.entrada,0)) - sum(coalesce(i.salida,0)) as saldo
from
	inventarios i
join
	documentos d
on
	i.ndocumento = d.ndocumento
where
	d.estado and
	i.fecha < '2026-06-01' and
	i.id_bodega = 245
group by
	i.id_bodega,
	i.id_prod_serv
having
	sum(coalesce(i.entrada,0)) - sum(coalesce(i.salida,0)) > 0
except
select
	a.id_bodega,
	a.id_prod_serv
from
	aux_listado_productos a
where
	a.entrada - a.salida > 0;
*/
--
DROP TABLE IF EXISTS aux_saldos_productos;
CREATE TEMP TABLE aux_saldos_productos AS
SELECT DISTINCT ON(i.id_bodega,i.id_prod_serv)
    i.id_bodega,
    i.id_prod_serv,
    i.pinventario
FROM
    inventarios i,
    aux_listado_productos lp,
    aux_params_reporte a
WHERE
    lp.id_prod_serv = i.id_prod_serv AND
    i.id_bodega = a.id_bodega AND
    i.fecha::DATE <= a.fecha_corte
ORDER BY
    i.id_bodega,
    i.id_prod_serv,
    i.fecha DESC;
	
--

DROP TABLE IF EXISTS aux_fecha_ult_venta;
CREATE TEMP TABLE aux_fecha_ult_venta AS
SELECT DISTINCT ON(dp.id_prod_serv)
    dp.id_prod_serv,
	dp.id_bodega,
	d.fecha
FROM
	datos_prod dp,
	documentos_standar dst,
	documentos_sucursales ds,
	documentos d,
	aux_listado_productos lp,
	aux_params_reporte a
WHERE
	dst.id_documento = ds.id_documento AND
	dst.nombre IN ('CAMBIOS','FACTURACION','FCONTINGENCIA','FCONTINGENCIAE','FCREDITO','FELECTRONICAPOS','FMANUAL','REMISIONES VENTA','SEPARADOS') AND
	d.ndocumento = dp.ndocumento AND
	ds.codigo_tipo = d.codigo_tipo AND
	d.estado AND
	d.fecha::DATE <= a.fecha_corte AND
	dp.id_bodega = a.id_bodega AND
	lp.id_prod_serv = dp.id_prod_serv    
ORDER BY
    dp.id_prod_serv,
    d.fecha DESC;

--
DROP TABLE IF EXISTS aux_pinventario_ultima_entrada_productos;
CREATE TEMP TABLE aux_pinventario_ultima_entrada_productos AS
SELECT DISTINCT ON(i.id_prod_serv)
    i.id_prod_serv,
    i.fecha::date as fecha_ult_compra,
    i.valor_ent AS pinventario
FROM
    documentos d,
    inventarios i,
    aux_listado_productos lp,
    aux_params_reporte a
WHERE
    d.ndocumento = i.ndocumento AND
    d.estado AND
    d.codigo_tipo IN ('EA','RC','IM','AT','IP','AF','AO') and -- jbe agrego AF AO
    lp.id_prod_serv = i.id_prod_serv AND
    i.fecha::DATE <= a.fecha_corte
ORDER BY
    i.id_prod_serv,
    i.fecha DESC;

--
-- Para las bonificaciones el pinventario es el el valor_ent 
-- de la compra antes de la compra con bonificacion
DROP TABLE IF EXISTS aux_pinventario_productos_bonificados;
CREATE TEMP TABLE aux_pinventario_productos_bonificados AS
SELECT DISTINCT ON(i.id_prod_serv)
    i.id_prod_serv,
    i.valor_ent AS pinventario
FROM
    documentos d,
    inventarios i,
    aux_pinventario_ultima_entrada_productos apb,
    aux_params_reporte a
WHERE
    d.ndocumento = i.ndocumento AND
    d.estado AND
    d.codigo_tipo IN ('EA','RC','IM','AT','IP','AF','AO') AND
    apb.id_prod_serv = i.id_prod_serv AND
    apb.pinventario = 0 AND
    i.valor_ent > 0 AND
    i.fecha::DATE <= a.fecha_corte
ORDER BY
    i.id_prod_serv,
    i.fecha DESC;


--
SELECT  
    foo.nombre_bodega,
    foo.nitcc_proveedor,
    foo.proveedor,
    foo.marca,
    foo.submarca,
    foo.linea,
    foo.grupo,
    foo.subgrupo,
    foo.codigo,
    foo.referencia,
    foo.descripcion,        
    ROUND(a.pinventario::NUMERIC,2) AS pcosto, --costo promedio
    CASE WHEN ROUND(aue.pinventario::NUMERIC,2) > 0 THEN ROUND(aue.pinventario::NUMERIC,2) ELSE CASE WHEN ROUND(apb.pinventario::NUMERIC,2) > 0 THEN ROUND(apb.pinventario::NUMERIC,2) ELSE CASE WHEN foo.pcosto > 0 THEN ROUND(foo.pcosto::NUMERIC,2) ELSE 0 END END END AS pcosto_ult_compra,    
    foo.entrada,
    foo.salida,
    COALESCE(foo.entrada,0)-COALESCE(foo.salida,0) AS saldo,
    ROUND((a.pinventario*(COALESCE(foo.entrada,0)-COALESCE(foo.salida,0)))::NUMERIC,2) AS vsaldo,	
	COALESCE(pv.pventa,0) AS pventa,
	COALESCE(afu.fecha::VARCHAR,'NA') AS ult_fecha_venta,
	foo.estado,
	COALESCE(aue.fecha_ult_compra::VARCHAR,'NA') AS fecha_ult_compra,
	current_date - aue.fecha_ult_compra as dias_en_inventario
FROM
    aux_params_reporte apr,
    aux_listado_productos AS foo
LEFT OUTER JOIN
    aux_saldos_productos a
ON
    foo.id_prod_serv = a.id_prod_serv AND
    foo.id_bodega = a.id_bodega
LEFT OUTER JOIN
    aux_pinventario_ultima_entrada_productos aue
ON
    foo.id_prod_serv = aue.id_prod_serv
LEFT OUTER JOIN
    aux_pinventario_productos_bonificados apb
ON
    foo.id_prod_serv = apb.id_prod_serv
LEFT OUTER JOIN
	pventa pv
ON
	foo.id_prod_serv = pv.id_prod_serv AND
	pv.id_catalogo = 1 and
	pv.id_lista = 1
LEFT OUTER JOIN
	aux_fecha_ult_venta afu
ON
	foo.id_prod_serv = afu.id_prod_serv AND
	foo.id_bodega = afu.id_bodega
WHERE
    (apr.bandera_saldo = 0 AND
    foo.entrada - foo.salida = 0) OR
    (apr.bandera_saldo = 1 AND
    foo.entrada - foo.salida != 0) OR
     (apr.bandera_saldo = -1)
ORDER BY
    nombre_bodega,
    proveedor,
    marca,
    submarca,
    linea,
    grupo,
    subgrupo,
    descripcion;

