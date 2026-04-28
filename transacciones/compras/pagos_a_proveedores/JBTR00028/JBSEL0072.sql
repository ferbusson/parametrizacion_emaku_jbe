select
	case 
		when cu.char_cta = '11100502' then 'TRANSFERNCIA BANCOLOMBIA'
		when cu.char_cta = '11100504' then 'TRANSFERNCIA AGRARIO'
		when cu.char_cta = '11100505' then 'TRANSFERNCIA DAVIVIENDA'
		when cu.char_cta = '11100506' then 'TRANSFERNCIA DAVIVIENDA'
		when cu.char_cta = '11100507' then 'TRANSFERNCIA BOGOTÁ'		
		when cu.char_cta = '21051004' then 'BCO / BANCOLOMBIA'		
		when cu.char_cta = '21051006' then 'BCO / BANCOLOMBIA'		
		when cu.char_cta = '21051008' then 'BCO / BOGOTÁ'		
		when cu.char_cta = '21051009' then 'BCO / DAVIVIENDA'		
        else 'CONSIGNACIÓN EN EFECTIVO'
			end as medio_pago
from
	documentos d
inner join
	libro_auxiliar la
on
	d.ndocumento = la.ndocumento 
inner join
	cuentas cu
on
	la.id_cta = cu.id_cta 
inner join
	tercero_def td
on
	d.ndocumento = td.ndocumento
where
	td.id = la.id_tercero
	and d.codigo_tipo = '?'
	and d.numero = lpad('?',10,'0')
	and cu.char_cta like '11%'
limit 1;