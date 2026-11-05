
--Fourth report: reporte inventarios


-- CLAUDE
-- Borrador query 4: Inventarios (Valor Inventario, Ventas del Mes -unidades y valor-)
-- Bodegas objetivo: 138 (PRINCIPAL), 241 (CARRERA21), 243 (CASA CARPINTERO), 245 (AMERICAS 15-15)
-- Reglas de negocio confirmadas por el usuario:
--   - Venta: documentos.codigo_tipo LIKE 'Z%' OR codigo_tipo LIKE 'G%'
--   - Devolucion (resta): documentos.codigo_tipo LIKE 'M%'
-- Valor de venta = "neto" (total con descuento, sin IVA), formula dada por el usuario:
--   neto = (cant * (pventa - pventa*descuento1/100)) / (1+iva/100)
--
-- Caveat de flujo de inventario (explicado por el usuario):
--   El pedido (O%) es el que mueve mercancia de la bodega de la sucursal
--   hacia la bodega de pedidos en proceso (id_bodega=140). La factura
--   (Z%/G%) solo saca el inventario de la bodega 140, por lo que la mayoria
--   de las lineas de datos_prod de una factura NO quedan con id_bodega de
--   la sucursal sino con id_bodega=140. La sucursal real de la venta se
--   recupera siguiendo info_documento.rf_documento de la factura hasta el
--   pedido que la origino, y usando las lineas datos_prod de ESE pedido
--   (que si tienen id_bodega de la sucursal). Si la factura no tiene
--   rf_documento (venta de mostrador sin pedido previo), se usan sus
--   propias lineas datos_prod (ya vienen con id_bodega de sucursal).
--   Las devoluciones (M%) siguen entrando directo a la bodega de la
--   sucursal, sin pasar por bodega 140.


drop table if exists aux_parametros_reporte;
create temp table aux_parametros_reporte as
select
    '?'::timestamp as fechai, 
    '?'::timestamp as fechaf;

drop table if exists aux_bodegas_reporte;
create temp table aux_bodegas_reporte as
select id, id_char, trim(nombre1||' '||nombre2||' '||apellido1||' '||apellido2||' '||razon_social) as nombre
from general
where id in (138,241,243,245);

-- 1. Valor de inventario actual (por bodega): ultimo saldo valorizado de cada
--    producto en la bodega, a la fecha de corte del reporte.
DROP TABLE IF EXISTS aux_listado_productos;
CREATE TEMP TABLE aux_listado_productos AS
SELECT
    iv.id_bodega,
    iv.id_prod_serv,
    sum(COALESCE(iv.entrada,0)) filter (where iv.fecha::date < a.fechai::date) AS entrada_inicial,
    sum(COALESCE(iv.salida,0)) filter (where iv.fecha::date < a.fechai::date) AS salida_inicial,
    sum(COALESCE(iv.entrada,0)) filter (where iv.fecha::date <= a.fechaf::date) AS entrada,
    sum(COALESCE(iv.salida,0)) filter (where iv.fecha::date <= a.fechaf::date) AS salida
FROM
    inventarios iv,
    aux_parametros_reporte a
where
	iv.fecha::DATE <= a.fechaf::date
	and iv.id_bodega in (select id from aux_bodegas_reporte)
GROUP BY
    iv.id_bodega,
    iv.id_prod_serv;

--
/*
DROP TABLE IF EXISTS aux_pinventario_por_bodega_y_producto;
CREATE TEMP TABLE aux_pinventario_por_bodega_y_producto AS
(SELECT DISTINCT ON(i.id_bodega,i.id_prod_serv)
    i.id_bodega,
    i.id_prod_serv,
    i.pinventario
FROM
    inventarios i,
    aux_listado_productos lp,
    aux_parametros_reporte a
WHERE
    lp.id_prod_serv = i.id_prod_serv AND
    i.id_bodega in (138) and
    i.fecha::DATE <= a.fechaf::date
ORDER BY
    i.id_bodega,
    i.id_prod_serv,
    i.fecha desc)
union all
(SELECT DISTINCT ON(i.id_bodega,i.id_prod_serv)
    i.id_bodega,
    i.id_prod_serv,
    i.pinventario
FROM
    inventarios i,
    aux_listado_productos lp,
    aux_parametros_reporte a
WHERE
    lp.id_prod_serv = i.id_prod_serv AND
    i.id_bodega in (241) and
    i.fecha::DATE <= a.fechaf::date
ORDER BY
    i.id_bodega,
    i.id_prod_serv,
    i.fecha desc)
union all
(SELECT DISTINCT ON(i.id_bodega,i.id_prod_serv)
    i.id_bodega,
    i.id_prod_serv,
    i.pinventario
FROM
    inventarios i,
    aux_listado_productos lp,
    aux_parametros_reporte a
WHERE
    lp.id_prod_serv = i.id_prod_serv AND
    i.id_bodega in (243) and
    i.fecha::DATE <= a.fechaf::date
ORDER BY
    i.id_bodega,
    i.id_prod_serv,
    i.fecha desc)
union all
(SELECT DISTINCT ON(i.id_bodega,i.id_prod_serv)
    i.id_bodega,
    i.id_prod_serv,
    i.pinventario
FROM
    inventarios i,
    aux_listado_productos lp,
    aux_parametros_reporte a
WHERE
    lp.id_prod_serv = i.id_prod_serv AND
    i.id_bodega in (245) and
    i.fecha::DATE <= a.fechaf::date
ORDER BY
    i.id_bodega,
    i.id_prod_serv,
    i.fecha desc)
    ;
	
DROP TABLE IF EXISTS aux_pinventario_por_bodega_y_producto_inicial;
CREATE TEMP TABLE aux_pinventario_por_bodega_y_producto_inicial AS
(SELECT DISTINCT ON(i.id_bodega,i.id_prod_serv)
    i.id_bodega,
    i.id_prod_serv,
    i.pinventario
FROM
    inventarios i,
    aux_listado_productos lp,
    aux_parametros_reporte a
WHERE
    lp.id_prod_serv = i.id_prod_serv AND
    i.id_bodega in (138) and
    i.fecha::DATE < a.fechai::date
ORDER BY
    i.id_bodega,
    i.id_prod_serv,
    i.fecha desc)
union all
(SELECT DISTINCT ON(i.id_bodega,i.id_prod_serv)
    i.id_bodega,
    i.id_prod_serv,
    i.pinventario
FROM
    inventarios i,
    aux_listado_productos lp,
    aux_parametros_reporte a
WHERE
    lp.id_prod_serv = i.id_prod_serv AND
    i.id_bodega in (241) and
    i.fecha::DATE < a.fechai::date
ORDER BY
    i.id_bodega,
    i.id_prod_serv,
    i.fecha desc)
union all
(SELECT DISTINCT ON(i.id_bodega,i.id_prod_serv)
    i.id_bodega,
    i.id_prod_serv,
    i.pinventario
FROM
    inventarios i,
    aux_listado_productos lp,
    aux_parametros_reporte a
WHERE
    lp.id_prod_serv = i.id_prod_serv AND
    i.id_bodega in (243) and
    i.fecha::DATE < a.fechai::date
ORDER BY
    i.id_bodega,
    i.id_prod_serv,
    i.fecha desc)
union all
(SELECT DISTINCT ON(i.id_bodega,i.id_prod_serv)
    i.id_bodega,
    i.id_prod_serv,
    i.pinventario
FROM
    inventarios i,
    aux_listado_productos lp,
    aux_parametros_reporte a
WHERE
    lp.id_prod_serv = i.id_prod_serv AND
    i.id_bodega in (245) and
    i.fecha::DATE < a.fechai::date
ORDER BY
    i.id_bodega,
    i.id_prod_serv,
    i.fecha desc)
    ;
*/
--
DROP TABLE IF EXISTS aux_valor_inventario_bodega;
CREATE TEMP TABLE aux_valor_inventario_bodega AS
SELECT
    i.id_bodega,
    round(sum(COALESCE(i.entrada,0)*COALESCE(i.valor_ent,0)
            - COALESCE(i.salida,0)*COALESCE(i.valor_sal,0))::numeric, 2) AS valor_inventario
FROM
    inventarios i
    JOIN documentos d ON d.ndocumento = i.ndocumento AND d.estado = true,
    aux_listado_productos lp,
    aux_parametros_reporte a
WHERE
    lp.id_prod_serv = i.id_prod_serv AND
    lp.id_bodega    = i.id_bodega AND
    i.id_bodega in (select id from aux_bodegas_reporte) and
    i.fecha::DATE <= a.fechaf::date
GROUP BY i.id_bodega;

/*
drop table if exists aux_valor_inventario_bodega;
create temp table aux_valor_inventario_bodega as
SELECT  
    foo.id_bodega,
    sum(ROUND((a.pinventario*(COALESCE(foo.entrada,0)-COALESCE(foo.salida,0)))::NUMERIC,2)) AS valor_inventario
FROM
    aux_listado_productos AS foo
JOIN
    aux_pinventario_por_bodega_y_producto a
ON
    foo.id_prod_serv = a.id_prod_serv AND
    foo.id_bodega = a.id_bodega
group by
	foo.id_bodega;*/


DROP TABLE IF EXISTS aux_valor_inventario_bodega_inicial;
CREATE TEMP TABLE aux_valor_inventario_bodega_inicial AS
SELECT
    i.id_bodega,
    round(sum(COALESCE(i.entrada,0)*COALESCE(i.valor_ent,0)
            - COALESCE(i.salida,0)*COALESCE(i.valor_sal,0))::numeric, 2) AS valor_inventario_inicial
FROM
    inventarios i
    JOIN documentos d ON d.ndocumento = i.ndocumento AND d.estado = true,
    aux_listado_productos lp,
    aux_parametros_reporte a
WHERE
    lp.id_prod_serv = i.id_prod_serv AND
    lp.id_bodega    = i.id_bodega AND
    i.id_bodega in (select id from aux_bodegas_reporte) and
    i.fecha::DATE < a.fechai
GROUP BY i.id_bodega;
/*
drop table if exists aux_valor_inventario_bodega_inicial;
create temp table aux_valor_inventario_bodega_inicial as
SELECT  
    foo.id_bodega,
    sum(ROUND((a.pinventario*(COALESCE(foo.entrada_inicial,0)-COALESCE(foo.salida_inicial,0)))::NUMERIC,2)) AS valor_inventario_inicial
FROM
    aux_listado_productos AS foo
JOIN
    aux_pinventario_por_bodega_y_producto_inicial a
ON
    foo.id_prod_serv = a.id_prod_serv AND
    foo.id_bodega = a.id_bodega
group by
	foo.id_bodega;
*/


-- 2a. Facturas (Z%/G%) dentro del rango, resolviendo el documento fuente
--     (pedido si existe, si no la propia factura) para sacar las lineas
--     datos_prod con la bodega real de la sucursal.
drop table if exists aux_facturas_fuente;
create temp table aux_facturas_fuente as
select
    d.ndocumento as bill_ndocumento,
    coalesce(idoc.rf_documento, d.ndocumento) as source_ndocumento
from
    documentos d
left join info_documento idoc on idoc.ndocumento = d.ndocumento
where
    d.estado
    and (d.codigo_tipo like 'Z%' or d.codigo_tipo like 'G%')
    and d.fecha::DATE >= (select fechai::date from aux_parametros_reporte)
    and d.fecha::date <=  (select fechaf::date from aux_parametros_reporte);

-- 2b. Ventas del mes (unidades y valor), netas de devoluciones, por bodega.
drop table if exists aux_ventas_mes_bodega;
create temp table aux_ventas_mes_bodega as
select
    id_bodega,
    sum(unidades) as unidades_vendidas,
    sum(valor) as valor_ventas
from (
    -- ventas: lineas del documento fuente (pedido o factura de mostrador)
    select
        dp.id_bodega,
        dp.cant as unidades,
        ((dp.cant * (dp.pventa - dp.pventa * coalesce(dp.descuento1,0)/100.0))::numeric(20,2)
            / (1 + coalesce(dp.iva,0)/100.0))::numeric(20,2) as valor
    from aux_facturas_fuente f
    join datos_prod dp on dp.ndocumento = f.source_ndocumento
    where dp.id_bodega in (select id from aux_bodegas_reporte)

    union all

    -- devoluciones: entran directo a la bodega de la sucursal, se restan
    select
        dp.id_bodega,
        -dp.cant as unidades,
        -((dp.cant * (dp.pventa - dp.pventa * coalesce(dp.descuento1,0)/100.0))::numeric(20,2)
            / (1 + coalesce(dp.iva,0)/100.0))::numeric(20,2) as valor
    from datos_prod dp
    join documentos d on d.ndocumento = dp.ndocumento
    where
        d.estado
        and d.codigo_tipo like 'M%'
        and dp.id_bodega in (select id from aux_bodegas_reporte)
        and d.fecha::DATE >= (select fechai::date from aux_parametros_reporte)
	    and d.fecha::date <=  (select fechaf::date from aux_parametros_reporte)

) x
group by
    id_bodega;

-- 2c. Costo de Ventas del mes menos devoluciones, por bodega.
drop table if exists aux_costo_ventas_mes_bodega;
create temp table aux_costo_ventas_mes_bodega as
select
    id_bodega,
    sum(valor::numeric(20,2)) as costo_ventas
from (
    -- ventas: lineas del documento fuente (pedido o factura de mostrador)
    select
        i.id_bodega,
        coalesce(i.salida,0)*coalesce(i.valor_sal,0) as valor
    from aux_facturas_fuente f
    join inventarios i on i.ndocumento = f.source_ndocumento
    where i.id_bodega in (select id from aux_bodegas_reporte)

    union all

    -- devoluciones: entran directo a la bodega de la sucursal, se restan
    select
        i.id_bodega,
        coalesce(-i.entrada,0)*coalesce(i.valor_ent,0) as valor
    from inventarios i
    join documentos d on d.ndocumento = i.ndocumento
    where
        d.estado
        and d.codigo_tipo like 'M%'
        and i.id_bodega in (select id from aux_bodegas_reporte)
        and d.fecha::DATE >= (select fechai::date from aux_parametros_reporte)
	    and d.fecha::date <=  (select fechaf::date from aux_parametros_reporte)

) x
group by
    id_bodega;    


-- 3. Resultado final por bodega
select
    b.id_char as codigo_bodega,
    b.nombre as descripcion_bodega,
    coalesce(vi.valor_inventario, 0) as valor_inventario,
    coalesce(vm.unidades_vendidas, 0) as ventas_del_mes_unidades,
    coalesce(vm.valor_ventas, 0) as ventas_del_mes_valor,
    coalesce(cv.costo_ventas, 0) as costo_ventas_del_mes_valor,
    coalesce(vm.valor_ventas, 0) - coalesce(cv.costo_ventas, 0) as utilidad_bruta,
    (((coalesce(vm.valor_ventas, 0) - coalesce(cv.costo_ventas, 0)) / coalesce(vm.valor_ventas, 0))*100)::numeric(20,2) as p_utilidad,
    /*(coalesce(cv.costo_ventas, 0) / ((coalesce(vii.valor_inventario_inicial, 0) + coalesce(vi.valor_inventario, 0))/2))::numeric(20,2) as rotacion,
    ((select (fechaf::date - fechai::date) +1  from aux_parametros_reporte) /
    	(coalesce(cv.costo_ventas, 0) / ((coalesce(vii.valor_inventario_inicial, 0) + coalesce(vi.valor_inventario, 0))/2))::numeric(20,2))::numeric(10,0) as dias_inventario*/
    case when (coalesce(vii.valor_inventario_inicial, 0) + coalesce(vi.valor_inventario, 0)) != 0 then
    	(coalesce(cv.costo_ventas, 0) / ((coalesce(vii.valor_inventario_inicial, 0) + coalesce(vi.valor_inventario, 0))/2))::numeric(20,2)
    else 0 end as rotacion,
    case when (coalesce(vii.valor_inventario_inicial, 0) + coalesce(vi.valor_inventario, 0)) != 0 then
    ((select (fechaf::date - fechai::date) +1  from aux_parametros_reporte) /
    	(coalesce(cv.costo_ventas, 0) / ((coalesce(vii.valor_inventario_inicial, 0) + coalesce(vi.valor_inventario, 0))/2))::numeric(20,2))::numeric(10,0) 
    else 0 end as dias_inventario
from
    aux_bodegas_reporte b
left join aux_valor_inventario_bodega vi on vi.id_bodega = b.id
left join aux_ventas_mes_bodega vm on vm.id_bodega = b.id
left join aux_costo_ventas_mes_bodega cv on cv.id_bodega = b.id
left join aux_valor_inventario_bodega_inicial vii on vii.id_bodega = b.id
order by
    b.id_char;