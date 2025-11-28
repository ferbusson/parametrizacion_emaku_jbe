--JBDEL0002.sql
with aux_parametro as (
    select
        '?'::BIGINT as nfactura
),
aux_movimientos_cartera as (
select distinct
	c.nfactura,
    c.ncomprobante,
    c.abono_comprobante 
from
    cartera c
where
    c.nfactura = (select nfactura from aux_parametro)
),
aux_validar_anticipos_a_restaurar as (
select
	a.ncomprobante,
	-- si el conteo es 0 significa que el anticipo se uso en su totalidad y se puede restaurar completo
	-- si es > 0 existe registro del anticipo con saldo pendiente por cruzar (nfactura = null) entonces a 
	-- ese registro le podemos sumar nuevamente el valor que se cruzó con la factura que se esta anulando 
	-- para dejarlo nuevamente disponible
	count(case when c.nfactura is null then 1 end) as bandera -- bandera = 0 se tomo el valor del anticipo completop, = 1 existe registro con nfactura = null para actualizarlo
from
    aux_movimientos_cartera a
left join
	cartera c
on
	c.ncomprobante = a.ncomprobante
group by 
	a.ncomprobante
),
aux_convierte_abono_tomado_a_disponible as (
update 
	cartera as ca
set
	nfactura = null
from
	aux_movimientos_cartera a
inner join
	aux_validar_anticipos_a_restaurar v
on
	a.ncomprobante = v.ncomprobante 
where
	ca.nfactura = a.nfactura 
	and ca.ncomprobante = v.ncomprobante 
	and v.bandera = 0
),
aux_retorna_saldo_a_anticipo as (
update 
	cartera as ca
set
	abono_comprobante = ca.abono_comprobante + a.abono_comprobante
from
	aux_movimientos_cartera a
inner join
	aux_validar_anticipos_a_restaurar v
on
	a.ncomprobante = v.ncomprobante 
where
	ca.nfactura is null 
	and ca.ncomprobante = a.ncomprobante 
	and v.bandera > 0)

delete from
	cartera as ca
using
	aux_movimientos_cartera a
inner join
	aux_validar_anticipos_a_restaurar v
on
	a.ncomprobante = v.ncomprobante 
	and v.bandera > 0
where
	ca.nfactura = a.nfactura
	and ca.ncomprobante = a.ncomprobante;