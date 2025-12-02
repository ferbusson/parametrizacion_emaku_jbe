--JBSEL0024

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
    d2.codigo_tipo||'-'||d2.numero::bigint as numero_pedido,
	coalesce(rf.prefijo,d.codigo_tipo) as prefijo,
	'CUFE: '||coalesce(cd.cufe,'') as cufe
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
	i.rf_documento = cp.ndocumento
left JOIN
    documentos d2
on
    d2.ndocumento = i.rf_documento
LEFT JOIN
	resolucion_documento rd
on
	d.ndocumento = rd.ndocumento
left JOIN
	resolucion_facturacion rf
on
	rf.id_resolucion_facturacion = rd.id_resolucion_facturacion
LEFT JOIN
	cufe_documentos cd
on
	cd.ndocumento = d.ndocumento
where
	d.codigo_tipo = '?'
	and d.numero = lpad('?',10,'0');