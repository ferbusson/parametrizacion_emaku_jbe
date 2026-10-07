--JBSEL0135
select
	trim(o.observacion) as observacion
from
	documentos d
join
	info_documento id
on 
	d.ndocumento = id.ndocumento 
join
	obs_documento o
on 
	id.rf_documento = o.ndocumento 
where
	d.codigo_tipo = '?' and
	d.numero = lpad('?',10,'0');