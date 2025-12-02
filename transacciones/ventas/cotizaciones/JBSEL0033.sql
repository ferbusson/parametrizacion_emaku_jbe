--JBSEL0033
with aux_parametros_query as(
select
	d.ndocumento
from
	documentos d
where
	d.codigo_tipo = '?'
	and d.numero = lpad('?',10,'0')
),
aux_saldo_inventario_productos as (
select
	i.id_bodega,
	i.id_prod_serv,
	sum(coalesce(entrada,0))-sum(coalesce(salida,0)) as saldo
from
	datos_prod dp
inner join
	inventarios i
on
	dp.id_prod_serv = i.id_prod_serv
	and dp.id_bodega = i.id_bodega 
where
	dp.ndocumento = (select a.ndocumento from aux_parametros_query a)
group by 
	i.id_bodega,
	i.id_prod_serv 
)
SELECT 
    ps.codigo,
    substring(it.nombre,1,66) as descripcion,
    coalesce(s.saldo,0) as saldo,
    cant,
    dp.id_lista,
    dp.pventa,
    dp.iva,
    dp.descuento1,
    0.00 as stotal,
    0.00 as v_dto,
    0.00 as neto,
    0.00 as tiva,
    0.00 as total,
    dp.id_prod_serv,
    0.00 as vlrunitarioimpr,
    ps.codigo,
    it.ref_proveedor,
    0.00 AS verde,
    ps.id_asiento_generico,
    0.00 AS basecinco,
    0.00 AS ivacinco,
    0.00 AS basediezynueve,
    0.00 AS ivadiezynueve,
    0.00 AS baseexento,
    0.00 AS ivaexento,
    0.00 AS baseexcluido,
    0.00 AS ivaexcluido,
    0.00 as netosinbolsa,
    1 as contadorlinea,
    0.00 as ya,
    0.00 as ym,
    0.00 as yi,
    0.00 as yxyl,
    0.00 as yxyg,
    0.00 as yxysg,
    0.00 as yxysm,
    0.00 as dctoxy,
	'' as cuenta,
	coalesce(dp.porcentajebp,-1) as porcentajebp,
	coalesce(dp.inc,-1) as inc,
	0.00 as subtotalsinbolsa,
	pv1.pventa as pventa1,
	pv2.pventa as pventa2,
	pv3.pventa as pventa3,
	pt.es_pintor::integer as espintor,
	pt.tiene_precio_base::integer as tienepreciobase
FROM 
    prod_serv ps,
     item it,
    tercero_def td,
    perfil_tercero pt,
    datos_prod dp
left join
	aux_saldo_inventario_productos s
on
	dp.id_prod_serv = s.id_prod_serv 
	and dp.id_bodega = s.id_bodega 
left join
	pventa pv1
on
	dp.id_prod_serv = pv1.id_prod_serv 
	and pv1.id_catalogo = 1
	and pv1.id_lista = 1
left join
	pventa pv2
on
	dp.id_prod_serv = pv2.id_prod_serv 
	and pv2.id_catalogo = 2
	and pv2.id_lista = 1
left join
	pventa pv3
on
	dp.id_prod_serv = pv3.id_prod_serv 
	and pv3.id_catalogo = 3
	and pv3.id_lista = 1
WHERE 
    dp.ndocumento= (select a.ndocumento from aux_parametros_query a) and
    dp.ndocumento = td.ndocumento and
    td.id = pt.id and
    ps.id_prod_serv=dp.id_prod_serv AND
     it.id_item=ps.id_item
ORDER BY
	dp.orden;