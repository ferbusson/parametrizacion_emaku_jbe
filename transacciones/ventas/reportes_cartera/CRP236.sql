--CRP236
DROP TABLE IF EXISTS args_cartera;
CREATE TEMP TABLE args_cartera AS
select
	/* Clase:
	0: saldo != 0
	1: saldo > 0
	2: saldo < 0*/
	'0'::CHARACTER(1) AS clase,	
	'2026-01-19'::DATE AS ffinal,
	''::CHARACTER(50) AS terceron, -- nombre de tercero
	''::CHARACTER(50) AS terceroi; -- id_char de tercero
	
DROP TABLE IF EXISTS aux_facturas_cartera;
CREATE TEMP TABLE aux_facturas_cartera AS
select
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
	cu.char_cta LIKE '1305%' AND
	c.id_cta = cu.id_cta AND
	c.idtercero=g.id AND
	(COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.razon_social,'') ILIKE '%'||f.terceron||'%' OR
                 g.id_char = f.terceroi)
GROUP by		
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
SELECT
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
	cu.char_cta like '1305%' AND
	d.fecha::date <= ffinal AND
	c.ncomprobante=d.ndocumento AND
	d.estado AND
	(COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.razon_social,'') ILIKE '%'||f.terceron||'%' OR
                 g.id_char = f.terceroi)
GROUP BY
	c.nfactura,
	codigo,
	TRIM(COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.razon_social,'')),
	c.idtercero;

---------------------------------------------------------------------------------------------------


select
	    foo.codigo, --id_char de tercero
        foo.nombre, --nombre de tercero
		coalesce(a.nombre,'--') as sucursal,
		d.fecha::date as fecha_mov,
		coalesce(rf.prefijo,d.codigo_tipo)||d.numero::integer||'/'||COALESCE(ex_documento,'*') as factura,
		(d.fecha::date + interval '1 day' * adc.dcredito)::date as fecha_vence,
		case when (d.fecha::date + interval '1 day' * adc.dcredito)::date >= current_date then saldo else 0 end as sin_vencer,
		case when current_date  - (d.fecha::date + interval '1 day' * adc.dcredito)::date between 1 and 30 then saldo else 0 end as vencidas_1_a_30,
		case when current_date  - (d.fecha::date + interval '1 day' * adc.dcredito)::date between 31 and 60 then saldo else 0 end as vencidas_31_a_60,
		case when current_date  - (d.fecha::date + interval '1 day' * adc.dcredito)::date between 61 and 90 then saldo else 0 end as vencidas_61_a_90,
		case when current_date  - (d.fecha::date + interval '1 day' * adc.dcredito)::date > 90 then saldo else 0 end as vencidas_mayor_90,
        saldo
FROM
	(select
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
	ON
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
ORDER BY
	codigo,
	fecha,
	nombre;
