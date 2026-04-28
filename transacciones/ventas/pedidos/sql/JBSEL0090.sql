with aux_numero_del_mes as(
SELECT extract('Month' from current_date) AS numero_mes_actual
)
select
	case 
		when a.numero_mes_actual = 1 then 'Enero'		
		when a.numero_mes_actual = 2 then 'Febrero'
		when a.numero_mes_actual = 3 then 'Marzo'
		when a.numero_mes_actual = 4 then 'Abril'
		when a.numero_mes_actual = 5 then 'Mayo'
		when a.numero_mes_actual = 6 then 'Junio'
		when a.numero_mes_actual = 7 then 'Julio'
		when a.numero_mes_actual = 8 then 'Agosto'
		when a.numero_mes_actual = 9 then 'Septiembre'
		when a.numero_mes_actual = 10 then 'Octubre'
		when a.numero_mes_actual = 11 then 'Noviembre'
		when a.numero_mes_actual = 12 then 'Diciembre'
end
from
	aux_numero_del_mes a;