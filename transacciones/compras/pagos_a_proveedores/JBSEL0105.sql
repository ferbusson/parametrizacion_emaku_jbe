--JBSEL0105
-- Consulta contabilizacion para impresion
-- Parametros: codigo_tipo, numero de documento
select
	c.codigo,
	cu.char_cta,
	--c.nombre,	
	cu.nombre as detalle,
	coalesce(doc_fac.codigo_tipo||'-'||doc_fac.numero::bigint,'--') as doc_fac,
	g.id_char,
	la.debe,
	la.haber,
	row_number() over(order by c.codigo) as tag
from
	documentos d
inner join
	libro_auxiliar la 
on
	d.ndocumento = la.ndocumento 
left join
	centrocosto c 
on 
	la.id_centrocosto = c.id_centrocosto 
inner join
	cuentas cu
on
	la.id_cta = cu.id_cta 
left join
	general g
on
	la.id_tercero = g.id
left join 
	documentos doc_fac
on
	la.ndocumento_enlace = doc_fac.ndocumento 
where
	d.codigo_tipo = '?' and 
	d.numero = lpad('?',10,'0')
order by
	case 
		when substring(cu.char_cta,1,2) = '22' then 0
		when substring(cu.char_cta,1,2) in ('42','41') then 1
		when substring(cu.char_cta,1,2) = '11' then 2
		when substring(cu.char_cta,1,2) = '23' then 3
		else cu.char_cta::bigint 
	end;