
--First report: saldos en cada banco 
drop table if exists aux_parametros_reporte;
create temp table aux_parametros_reporte as
select
	'?'::timestamp as fechai,
	'?'::timestamp as fechaf;

drop table if exists aux_saldos_anteriores;
create temp table aux_saldos_anteriores as
select
	cu.char_cta as codigo,
	cu.nombre  as descripcion_cuenta,
	sum(coalesce(la.debe,0)::numeric(20,2)) - sum(coalesce(la.haber,0)::numeric(20,2)) as saldo_anterior
from 	
	libro_auxiliar la 
join
	cuentas cu
on
	la.id_cta = cu.id_cta
join
	documentos d
on
	la.ndocumento = d.ndocumento 
where
	d.estado
	and (cu.char_cta like '11%' or cu.char_cta like '2105%')	
	and cu.char_cta not in ('11051001','11051501') -- excluimos la caja menor y caja sencilla
	and la.fecha < (select fechai from aux_parametros_reporte)
group by
	cu.char_cta,
	cu.nombre;


drop table if exists aux_saldos_del_periodo;
create temp table aux_saldos_del_periodo as
select
	cu.char_cta as codigo,
	cu.nombre  as descripcion_cuenta,
	sum(coalesce(la.debe,0)::numeric(20,2)) as debe,
	sum(coalesce(la.haber,0)::numeric(20,2)) as haber,
	sum(coalesce(la.debe,0)::numeric(20,2)) - sum(coalesce(la.haber,0)::numeric(20,2)) as saldo
from 	
	libro_auxiliar la 
join
	cuentas cu
on
	la.id_cta = cu.id_cta
join
	documentos d
on
	la.ndocumento = d.ndocumento
where
	d.estado
	and (cu.char_cta like '11%' or cu.char_cta like '2105%')
	and la.fecha >= (select fechai from aux_parametros_reporte)
	and la.fecha < (select fechaf + interval '1 day' from aux_parametros_reporte)
group by
	cu.char_cta,
	cu.nombre;

drop table if exists aux_resultado_todas_las_cuentas;
create temp table aux_resultado_todas_las_cuentas as
select
	sa.codigo,
	sa.descripcion_cuenta,
	coalesce(sa.saldo_anterior,0) as saldo_anterior,
	coalesce(sp.debe,0) as movimiento_debito,
	coalesce(sp.haber,0) as movimiento_credito,
	coalesce(sp.saldo,0) as saldo_final,
	row_number() over (order by sa.codigo) as serial
from
	aux_saldos_anteriores sa
left join
	aux_saldos_del_periodo sp	
on
	sa.codigo = sp.codigo
where
	coalesce(sa.saldo_anterior,0) != 0;

--
-- *id_para_totales: se usa al momento de generar el reporte, el reporteador puede agrupar 
-- por este criterio para sumar columnas de totales.
-- *id_clasificacion: se usa para ordenar el resultado y el reporteador puede usar esta 
-- columna para mostrar la categoria en la que se encuentran los registros.
-- *clasificacion: se usa para mostrar la categoria en la que se encuentran los registros

select
	0 as id_para_totales,
	0 as id_clasificacion,
	'Efectivo' as clasificacion,
	a.codigo,
	a.descripcion_cuenta,
	a.saldo_anterior,
	a.movimiento_debito,
	a.movimiento_credito,
	a.saldo_final,
	a.serial
from
	aux_resultado_todas_las_cuentas a
where
	a.codigo like '1105%'
union
select
	0 as id_para_totales,
	1 as id_clasificacion,
	'Cuentas Corrientes' as clasificacion,
	a.codigo,
	a.descripcion_cuenta,
	a.saldo_anterior,
	a.movimiento_debito,
	a.movimiento_credito,
	a.saldo_final,
	a.serial
from
	aux_resultado_todas_las_cuentas a
where
	a.codigo like '1110%'
union
select
	0 as id_para_totales,
	2 as id_clasificacion,
	'Cuentas de Ahorro' as clasificacion,
	a.codigo,
	a.descripcion_cuenta,
	a.saldo_anterior,
	a.movimiento_debito,
	a.movimiento_credito,
	a.saldo_final,
	a.serial
from
	aux_resultado_todas_las_cuentas a
where
	a.codigo like '1120%'
	and a.descripcion_cuenta not ilike '%fidu%' --excluimos fiducias
union
select
	0 as id_para_totales,
	3 as id_clasificacion,
	'Fiducuentas' as clasificacion,
	a.codigo,
	a.descripcion_cuenta,
	a.saldo_anterior,
	a.movimiento_debito,
	a.movimiento_credito,
	a.saldo_final,
	a.serial
from
	aux_resultado_todas_las_cuentas a
where
	a.codigo like '1120%'
	and a.descripcion_cuenta ilike '%fidu%' --incluimos fiducias
union
select
	1 as id_para_totales,
	4 as id_clasificacion,
	'Creditos Bancarios y TC' as clasificacion,
	a.codigo,
	a.descripcion_cuenta,
	a.saldo_anterior,
	a.movimiento_debito,
	a.movimiento_credito,
	a.saldo_final,
	a.serial
from
	aux_resultado_todas_las_cuentas a
where
	a.codigo like '2105%'
	and a.descripcion_cuenta not ilike '%tarjeta%' --excluimos tarjetas
union
select
	1 as id_para_totales,
	5 as id_clasificacion,
	'Creditos Bancarios y TC' as clasificacion,
	a.codigo,
	a.descripcion_cuenta,
	a.saldo_anterior,
	a.movimiento_debito,
	a.movimiento_credito,
	a.saldo_final,
	a.serial
from
	aux_resultado_todas_las_cuentas a
where
	a.codigo like '2105%'
	and a.descripcion_cuenta ilike '%tarjeta%' --incluimos tarjetas
order by
	id_para_totales,
	id_clasificacion,
	serial;
