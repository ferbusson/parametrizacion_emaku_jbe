SELECT
	cu.char_cta,
	p.concepto AS detalle,
	p.debe,
	p.haber,
	pc.base,
	g.id_char,
	d.codigo_tipo||'-'||d.numero::BIGINT AS documento_enlace,
	cc.codigo AS codigo_centrocosto,
	NULL AS codigo_subcentrocosto,
	NULL AS vk,
	cu.nombre AS nombre_cuenta,
	pc.terceros,
	pc.centro ,
	pc.scentro,
	pc.vinculada,
	pc.edocumento,
	pc.retencion,
	g.id AS id_tercero,
	NULL AS id_producto,
	cu.id_cta,
	NEXTVAL('tagdata') AS tag,
	LTRIM(COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||COALESCE(g.razon_social,'')) AS nombre_tercero,
	d.ndocumento,
	SUBSTRING(g.id_char||'-'||TRIM(COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||COALESCE(g.razon_social,'')),1,30) AS nombretimp,
	SUBSTRING(p.concepto,1,41) AS detalleimp,
	substring(case when id.ex_documento is null or id.ex_documento = '' then d.codigo_tipo||'-'||d.numero::bigint else d.codigo_tipo||'-'||d.numero::bigint||'/'||COALESCE(id.ex_documento,'') end,1,15) as numero_exdocumento
FROM
	plantillas_nota_contable p
LEFT OUTER JOIN
	centrocosto cc
ON
	TRIM(p.centrocosto) != '-' AND
	TRIM(p.centrocosto) = TRIM(cc.codigo)
LEFT OUTER JOIN
	cuentas cu
ON
	TRIM(p.cuenta) = TRIM(cu.char_cta)
LEFT OUTER JOIN
	perfil_cta pc
ON
	cu.id_cta = pc.id_cta
LEFT OUTER JOIN
	general g
ON
	TRIM(p.tercero) != '-' AND
	TRIM(p.tercero) = TRIM(g.id_char)
LEFT OUTER JOIN
	documentos d
ON
	TRIM(p.documento) != '-' AND
	SUBSTRING(p.documento,1,2) = d.codigo_tipo AND
	LPAD(SUBSTRING(p.documento,4,LENGTH(TRIM(p.documento))),10,'0') = d.numero
left outer join
	info_documento id
on
	d.ndocumento = id.ndocumento 
WHERE					 	
	p.ndocumento = '?'
ORDER BY
	p.orden;