--retorna el id_centrocosto de una de las facturas seleccionadas por el usuario
--?
/*select
	la.id_centrocosto
from
	aux_facturas_pagadas a -- esta tabla la genera el usuario al seleccionar una factura
join
	libro_auxiliar la 
on
	a.nfactura = la.ndocumento
where
	a.valor_abono != 0
	and la.id_centrocosto is not null
limit 1;*/

SELECT
	1;