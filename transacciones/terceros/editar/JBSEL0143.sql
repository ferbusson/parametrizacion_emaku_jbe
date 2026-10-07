--JBSEL0143
select --? descarta tipo identificacion
	TRIM(ot.observacion)
from
	observaciones_tercero ot
where
	ot.id = (select id from general where trim(id_char) = trim('?'));