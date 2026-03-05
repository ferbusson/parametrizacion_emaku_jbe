--JBSEL0085
select
	cu.id_cta,
	trim(cu.nombre) as nombre
from
	cuentas cu
where
	cu.tipo = false
	and cu.char_cta like '130505%'
	and cu.char_cta != '13050599'
order by
	cu.char_cta;