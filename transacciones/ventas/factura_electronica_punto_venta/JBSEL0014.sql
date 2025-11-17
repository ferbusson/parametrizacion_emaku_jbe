select
	trim(ie.sigla) as sigla,
	trim(u.login) as login,
	trim(i.ex_documento) as norden,
	coalesce(trim(g.id_char),'') as id_char_tercero_referente,
	trim(coalesce(g.nombre1,'')||' '||coalesce(g.nombre2,'')||' '||coalesce(g.apellido1,'')||' '||coalesce(g.apellido2,'')||' '||coalesce(g.razon_social,'')) as nombre_tercero_referente,
	trim(cp.direccion) as direccion, -- dir de contacto
	trim(cp.telefono) as telefono, -- tel de contacto
	i.id_vendedor,
	d.fecha::date + i.vencimiento as vencimiento,
	d.ndocumento,
    d2.codigo_tipo||'-'||d2.numero::bigint as numero_pedido
from
	documentos d
inner join
	info_documento i 
on
	d.ndocumento = i.ndocumento 
inner join
	info_empleado ie
on
	i.id_vendedor = ie.id
inner join
	usuarios u
on 	
	i.id_usuario = u.id_usuario 
left join
	general g
on
	i.id_tercero_referente = g.id
left join
	contacto_pedidos cp
on
	d.ndocumento = cp.ndocumento
left JOIN
    documentos d2
on
    d2.ndocumento = i.rf_documento
where
	d.codigo_tipo = '?'
	and d.numero = lpad('?',10,'0');