--JBSEL0141
drop table if exists aux_comprobante_consultado;
create temp table aux_comprobante_consultado as
select
	d.ndocumento
from
	documentos d
where
	d.codigo_tipo = '?'
	and d.numero = lpad('?',10,'0');

SELECT
	'Abono a CxP comprobante de egreso - Descuentos' as concepto,
	cc.codigo as centrocosto,
	'NULL' as scc,
	'NULL' as vk,
	c.char_cta,
	'NULL' as id_tercero,
	'NULL' as id_producto,
	'NULL' as ndocumento_fac,
	la.debe,
	la.haber,
	'NULL' as id_activo
FROM
	cuentas c,
	aux_comprobante_consultado a,
	libro_auxiliar la,
	centrocosto cc	
where
	a.ndocumento = la.ndocumento and
	la.id_centrocosto = cc.id_centrocosto and
	la.id_cta = c.id_cta and
	substring(c.char_cta,1,1) in ('4') 
ORDER BY
	char_cta;