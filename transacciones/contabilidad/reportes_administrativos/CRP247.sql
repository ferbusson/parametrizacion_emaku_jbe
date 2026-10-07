--First report: saldos en cada banco 
drop table if exists aux_parametros_reporte;
create temp table aux_parametros_reporte as
select
	'?'::date as fechai,
	'?'::date as fechaf;

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
	and cu.char_cta not in ('11051001','11051501','11053001','11100503','11100508','11200506','21051001','21051002','21051004')
	and la.fecha::date < (select fechai::date from aux_parametros_reporte)
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
	and cu.char_cta not in ('11051001','11051501','110530001','11100503','11100508','11200506','21051001','21051002','21051004')
	and la.fecha::date >= (select fechai::date from aux_parametros_reporte)
	and la.fecha::date <= (select fechaf::date from aux_parametros_reporte)
group by
	cu.char_cta,
	cu.nombre;

select
	sa.codigo,
	sa.descripcion_cuenta,
	coalesce(sa.saldo_anterior,0) as saldo_anterior,
	coalesce(sp.debe,0) as movimiento_debito,
	coalesce(sp.haber,0) as movimiento_credito,
	coalesce(sa.saldo_anterior,0) + coalesce(sp.saldo,0) as saldo_final
from
	aux_saldos_anteriores sa
left join	
	aux_saldos_del_periodo sp
on
	sa.codigo = sp.codigo
order by
	sa.codigo;
