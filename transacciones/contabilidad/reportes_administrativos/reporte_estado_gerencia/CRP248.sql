
--Second report: CxC por edades
DROP TABLE IF EXISTS args_cartera;
CREATE TEMP TABLE args_cartera AS
select
	/* Clase:
	0: saldo != 0
	1: saldo > 0
	2: saldo < 0*/
	'0'::CHARACTER(1) AS clase,	
	'?'::DATE AS ffinal,
	trim(''::character(10)) AS char_cta,
	''::CHARACTER(50) AS terceron, -- nombre de tercero
	''::CHARACTER(50) AS terceroi; -- id_char de tercero
	
DROP TABLE IF EXISTS aux_facturas_cartera;
CREATE TEMP TABLE aux_facturas_cartera AS
select
	cu.char_cta,
	cu.nombre as tipo_credito,
	c.idtercero,
	g.id_char  AS codigo,
	TRIM(COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.razon_social,'')) AS nombre,
	c.nfactura,
	SUM(c.total_factura) AS vfactura,
	i.ex_documento
FROM
	cartera c,
	info_documento i,
	general g,
	perfil_tercero pt,
	cuentas cu,
	args_cartera f,
	documentos d
where
	d.ndocumento=i.ndocumento AND
	g.id = pt.id AND
	d.ndocumento=c.nfactura AND
	d.fecha::date <=ffinal::date AND
	d.estado AND
	case when f.char_cta = '' or f.char_cta is null then cu.char_cta LIKE '1305%' --AND cu.char_cta NOT IN ('13050502','13050504')
		else cu.char_cta = f.char_cta end AND
	c.id_cta = cu.id_cta AND
	c.idtercero=g.id AND
	(COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.razon_social,'') ILIKE '%'||f.terceron||'%' OR
                 g.id_char = f.terceroi)
GROUP by		
	cu.char_cta,
	cu.nombre,
	ffinal,
	c.idtercero,
	g.id_char,
	TRIM(COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.razon_social,'')),
	c.nfactura,
	i.ex_documento;

DROP TABLE IF EXISTS aux_dias_credito_factura;
CREATE TEMP TABLE aux_dias_credito_factura AS
select
	ca.nfactura,
	ca.dcredito
from
	cartera ca
inner join
	aux_facturas_cartera a
on
	ca.nfactura = a.nfactura
where
	ca.ncomprobante is null;

DROP TABLE IF EXISTS aux_abonos_hechos_cartera;
CREATE TEMP TABLE aux_abonos_hechos_cartera AS
select
	cu.char_cta,
	cu.nombre as tipo_credito,
	c.idtercero,
	g.id_char  AS codigo,
	TRIM(COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.razon_social,'')) AS nombre,
	c.nfactura,
	SUM(cargo_comprobante)-(SUM(c.abono_comprobante)+SUM(c.dcto_comprobante)) AS vcomprobante
FROM
	cartera c,
	cuentas cu,
	documentos d,
	args_cartera f,
	general g,
	perfil_tercero pt
WHERE
	pt.id=g.id AND
	g.id=c.idtercero AND
	cu.id_cta=c.id_cta AND
	case when f.char_cta = '' or f.char_cta is null then cu.char_cta LIKE '1305%'  --AND cu.char_cta NOT IN ('13050502','13050504')
		else cu.char_cta = f.char_cta end AND
	d.fecha::date <= ffinal AND
	c.ncomprobante=d.ndocumento AND
	d.estado AND
	(COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.razon_social,'') ILIKE '%'||f.terceron||'%' OR
                 g.id_char = f.terceroi)
GROUP by
	cu.char_cta,
	cu.nombre,
	c.nfactura,
	codigo,
	TRIM(COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.razon_social,'')),
	c.idtercero;

---------------------------------------------------------------------------------------------------

select
	foo.nombre_credito,		
	foo.sin_vencer,
	foo.vencidas_1_a_30,
	foo.vencidas_31_a_60,
	foo.vencidas_61_a_90,
	foo.vencidas_mayor_90,
    foo.saldo
from
	(select
			case when foo.char_cta = '13050501' or foo.char_cta = '13050503' then 'CREDITOS JBE' when foo.char_cta = '13050502' then 'SISTECREDITO' when foo.char_cta = '13050504' then 'ADDI' end as nombre_credito,		
			sum(case when (d.fecha::date + interval '1 day' * adc.dcredito)::date >= ac.ffinal then saldo else 0 end) as sin_vencer,
			sum(case when ac.ffinal  - (d.fecha::date + interval '1 day' * adc.dcredito)::date between 1 and 30 then saldo else 0 end) as vencidas_1_a_30,
			sum(case when ac.ffinal  - (d.fecha::date + interval '1 day' * adc.dcredito)::date between 31 and 60 then saldo else 0 end) as vencidas_31_a_60,
			sum(case when ac.ffinal  - (d.fecha::date + interval '1 day' * adc.dcredito)::date between 61 and 90 then saldo else 0 end) as vencidas_61_a_90,
			sum(case when ac.ffinal  - (d.fecha::date + interval '1 day' * adc.dcredito)::date > 90 then saldo else 0 end) as vencidas_mayor_90,
	        sum(saldo) as saldo
	FROM
		(select
			c.char_cta,
			COALESCE(c.codigo,co.codigo) AS codigo,
			COALESCE(c.nombre,co.nombre) AS nombre,
			COALESCE(c.nfactura,co.nfactura) AS nfactura,
			COALESCE(c.vfactura,0) AS vfactura,
			COALESCE(co.vcomprobante,0) AS vcomprobante,
			COALESCE(c.vfactura,0)+COALESCE(co.vcomprobante,0) AS saldo,
			c.ex_documento
		FROM
			aux_facturas_cartera c
		FULL OUTER JOIN
			aux_abonos_hechos_cartera co
		on
			co.char_cta = c.char_cta and
			co.nfactura=c.nfactura AND
			c.idtercero=co.idtercero) AS foo,
		args_cartera ac,
		aux_dias_credito_factura adc,
		documentos d
		left join
			documentos_sucursales ds
		on
			d.codigo_tipo = ds.codigo_tipo
		left join
			administracion_sucursales a
		on
			ds.id_administracion_sucursales = a.id_administracion_sucursales
		left join
			resolucion_documento rd
		on
			d.ndocumento = rd.ndocumento
		left join
			resolucion_facturacion rf 
		on
			rd.id_resolucion_facturacion = rf.id_resolucion_facturacion
	where
		foo.nfactura = adc.nfactura and
		foo.nfactura=d.ndocumento AND
		((saldo!=0 AND 
		ac.clase = '0') OR
		(saldo!=0 AND saldo>0 AND ac.clase = '1') OR
		(saldo!=0 AND saldo<0 AND ac.clase = '2'))
	group by
		case when foo.char_cta = '13050501' or foo.char_cta = '13050503' then 'CREDITOS JBE' when foo.char_cta = '13050502' then 'SISTECREDITO' when foo.char_cta = '13050504' then 'ADDI' end
		) as foo
order by
	case when foo.nombre_credito = 'CREDITOS JBE' then 0
		when foo.nombre_credito = 'SISTECREDITO' then 1 else 2 END;
