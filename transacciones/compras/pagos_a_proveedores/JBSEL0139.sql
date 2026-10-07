--JBSEL0139
DROP TABLE IF EXISTS aux_registro_descuentos;
CREATE TABLE aux_registro_descuentos
(
	valor_descuento numeric(20,2),	
	id_centrocosto integer
);

INSERT INTO aux_registro_descuentos (valor_descuento,id_centrocosto) VALUES 
?;

select
	'Abono a CxP comprobante de egreso - Descuentos' as concepto,
	cc.codigo as centrocosto,
	'NULL' as scc,
	'NULL' as vk,
	'42104001' as char_cta,
	'NULL' as id_tercero,
	'NULL' as id_producto,
	'NULL' as ndocumento_fac,
	0.0::numeric(20,2) as debe,
	valor_descuento as haber,
	'NULL' as id_activo
FROM
	aux_registro_descuentos a
join
	centrocosto cc
on
	a.id_centrocosto = cc.id_centrocosto
where
	a.valor_descuento > 0.00
ORDER BY
	char_cta;


