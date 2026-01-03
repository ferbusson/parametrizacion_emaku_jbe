-- MTSEL0731 NEW
DROP TABLE IF EXISTS aux_parametros_reporte;
CREATE TEMP TABLE aux_parametros_reporte as
select 
	fecha_corte,
	substring(id_bodega_ppal,1,position('-' in id_bodega_ppal)-1) as id_bodega_ppal,
	substring(id_bodega_ppal,position('-' in id_bodega_ppal)+1,length(id_bodega_ppal)) as id_administracion_sucursales
from
	(SELECT 
		'?'::VARCHAR AS fecha_corte,
		'?'::VARCHAR AS id_bodega_ppal) as foo;
	
-- validacion que evita error al abrir el formulario
UPDATE
	aux_parametros_reporte
SET
	fecha_corte = '1900-01-01'::DATE,
	id_bodega_ppal = '-1'
WHERE
	TRIM(fecha_corte) = '';
	
-- Inicia Conexiones remotas
DROP TABLE IF EXISTS remote_cnx;
CREATE TEMP TABLE remote_cnx AS
SELECT
    'CNX'||round((random()*1000000)::numeric,0) AS cnx,
    host,
    dbname,
    usuario,
    clave
FROM
    dblink_sucursales d,
    aux_parametros_reporte a
WHERE
    d.id_bodega = a.id_bodega_ppal::INTEGER AND
	d.host != 'localhost' AND -- evita conexiones con la misma base de datos lacali cuando se recibe id de bodega 138 1252
    d.online;				  -- el reporte local no entra por dblink

-- SE ESTABLECE EL LINK CON EL SERVIDOR 
DROP TABLE IF EXISTS cnx_remote;
CREATE TEMP TABLE cnx_remote AS 
SELECT
    (SELECT dblink_connect(cnx,'host='||dl.host||' dbname='||dl.dbname||' user='||dl.usuario||' port=5432 password='||dl.clave||''))
FROM
    remote_cnx AS dl;
	
--Guardar parametros reporte en bd sucursal
DROP TABLE IF EXISTS aux_exec_query;
		CREATE TEMP TABLE aux_exec_query AS 
		SELECT
			(SELECT
				dblink_exec((SELECT cnx FROM remote_cnx),
				'
				DROP TABLE IF EXISTS aux_parametros_reporte_sucursal02;
				CREATE TABLE aux_parametros_reporte_sucursal02 (fecha_corte VARCHAR, id_bodega_ppal VARCHAR);
				'));

DROP TABLE IF EXISTS aux_exec_query;
CREATE TEMP TABLE aux_exec_query AS 
SELECT
	(SELECT
		dblink_exec((SELECT cnx FROM remote_cnx),
			'INSERT INTO aux_parametros_reporte_sucursal02 SELECT '''||foo.fecha_corte||''','''||foo.id_bodega_ppal||''' '))
FROM
	(SELECT
		a.fecha_corte,
		a.id_bodega_ppal
	FROM
		aux_parametros_reporte a) as foo;
		
DROP TABLE IF EXISTS aux_resultado_repo_remoto;
CREATE TEMP TABLE aux_resultado_repo_remoto AS 
SELECT
	_id_renglon AS id,
	_nom_suc AS nom_suc,
	_nombre_medio_pago AS nombre,
	_valor_mp AS valor,
	_id_administracion_sucursales AS id_administracion_sucursales
FROM
	dblink((SELECT cnx FROM remote_cnx),'SELECT
	_id_renglon,
	_nom_suc,
	_nombre_medio_pago,
	_valor_mp,
	_id_administracion_sucursales
FROM
	ventas_del_dia_gerencia();') AS rr(_id_renglon integer, _nom_suc VARCHAR(100), _nombre_medio_pago VARCHAR, _valor_mp double precision, _id_administracion_sucursales integer);

DROP TABLE IF EXISTS cnx_remote;
CREATE TEMP TABLE cnx_remote AS 
SELECT dblink_disconnect(cnx) FROM remote_cnx;

-- Fin Conexiones remotas

DROP TABLE IF EXISTS tipo_docs;
CREATE TEMP TABLE tipo_docs AS
SELECT DISTINCT
	ad.id_administracion_sucursales,
	ad.nombre AS nom_suc,
    CASE WHEN ds.nombre IN ('DEVOLUCION VENTA','DVENTA ELECTRONICA') THEN FALSE ELSE TRUE END AS suma,
	dv.codigo_tipo
FROM
	documentos_standar ds,
	administracion_sucursales ad,
	documentos_sucursales dv,
	aux_parametros_reporte a
WHERE
	ds.id_documento=dv.id_documento AND
	dv.id_administracion_sucursales=ad.id_administracion_sucursales AND
	CASE WHEN TRIM(a.id_bodega_ppal) = '' THEN TRUE ELSE ad.id_bodega_ppal=a.id_bodega_ppal::INTEGER END and
	CASE WHEN TRIM(a.id_bodega_ppal) = '' THEN TRUE ELSE ad.id_administracion_sucursales=a.id_administracion_sucursales::INTEGER END AND
	ds.nombre IN ('FACTURACION',
				  'FMANUAL',
				  'FELECTRONICAPOS',
				  'FCONTINGENCIAE',
				  'FCREDITO',
				  'FCONTINGENCIA',
				  'CAMBIOS',
                  'DEVOLUCION VENTA',
                  'DVENTA ELECTRONICA',
				 'COMPROBANTES INGRESO');
				
-- se excluyen comprobantes de ingreso, se usa para controlar las consignaciones factura multipago
DROP TABLE IF EXISTS tipo_docs_solo_facturacion;
CREATE TEMP TABLE tipo_docs_solo_facturacion AS
SELECT DISTINCT
	ad.id_administracion_sucursales,
	ad.nombre AS nom_suc,
    CASE WHEN ds.nombre IN ('DEVOLUCION VENTA','DVENTA ELECTRONICA') THEN FALSE ELSE TRUE END AS suma,
	dv.codigo_tipo
FROM
	documentos_standar ds,
	administracion_sucursales ad,
	documentos_sucursales dv,
	aux_parametros_reporte a
WHERE
	ds.id_documento=dv.id_documento AND
	dv.id_administracion_sucursales=ad.id_administracion_sucursales AND
	CASE WHEN TRIM(a.id_bodega_ppal) = '' THEN TRUE ELSE ad.id_bodega_ppal=a.id_bodega_ppal::INTEGER END and
	CASE WHEN TRIM(a.id_bodega_ppal) = '' THEN TRUE ELSE ad.id_administracion_sucursales=a.id_administracion_sucursales::INTEGER END AND
	ds.nombre IN ('FACTURACION',
				  'FMANUAL',
				  'FELECTRONICAPOS',
				  'FCONTINGENCIAE',
				  'FCREDITO',
				  'FCONTINGENCIA',
				  'CAMBIOS',
                  'DEVOLUCION VENTA',
                  'DVENTA ELECTRONICA');

DROP TABLE IF EXISTS tipo_doc_comprobante;
CREATE TEMP TABLE tipo_doc_comprobante AS
SELECT DISTINCT
	ad.id_administracion_sucursales,
	dv.codigo_tipo
FROM
	documentos_standar ds,
	administracion_sucursales ad,
	documentos_sucursales dv,
	aux_parametros_reporte a
WHERE
	ds.id_documento=dv.id_documento AND
	dv.id_administracion_sucursales=ad.id_administracion_sucursales AND
	CASE WHEN TRIM(a.id_bodega_ppal) = '' THEN TRUE ELSE ad.id_bodega_ppal=a.id_bodega_ppal::INTEGER END and
	CASE WHEN TRIM(a.id_bodega_ppal) = '' THEN TRUE ELSE ad.id_administracion_sucursales=a.id_administracion_sucursales::INTEGER END AND
	ds.nombre IN ('COMPROBANTES INGRESO',
				 'CAMBIOS',
                  'DEVOLUCION VENTA',
                  'DVENTA ELECTRONICA');

DROP TABLE IF EXISTS tipo_doc_devoluciones;
CREATE TEMP TABLE tipo_doc_devoluciones AS
SELECT DISTINCT
	ad.id_administracion_sucursales,
	dv.codigo_tipo
FROM
	documentos_standar ds,
	administracion_sucursales ad,
	documentos_sucursales dv,
	aux_parametros_reporte a
WHERE
	ds.id_documento=dv.id_documento AND
	dv.id_administracion_sucursales=ad.id_administracion_sucursales AND
	CASE WHEN TRIM(a.id_bodega_ppal) = '' THEN TRUE ELSE ad.id_bodega_ppal=a.id_bodega_ppal::INTEGER END and
	CASE WHEN TRIM(a.id_bodega_ppal) = '' THEN TRUE ELSE ad.id_administracion_sucursales=a.id_administracion_sucursales::INTEGER END AND
	ds.nombre IN ('DEVOLUCION VENTA',
                  'DVENTA ELECTRONICA');

DROP TABLE IF EXISTS tipo_doc_abonos_cartera;
CREATE TEMP TABLE tipo_doc_abonos_cartera AS
SELECT DISTINCT
	ad.id_administracion_sucursales,
	dv.codigo_tipo
FROM
	documentos_standar ds,
	administracion_sucursales ad,
	documentos_sucursales dv,
	aux_parametros_reporte a
WHERE
	ds.id_documento=dv.id_documento AND
	dv.id_administracion_sucursales=ad.id_administracion_sucursales AND
	CASE WHEN TRIM(a.id_bodega_ppal) = '' THEN TRUE ELSE ad.id_bodega_ppal=a.id_bodega_ppal::INTEGER END and
	CASE WHEN TRIM(a.id_bodega_ppal) = '' THEN TRUE ELSE ad.id_administracion_sucursales=a.id_administracion_sucursales::INTEGER END AND
	ds.nombre IN ('COMPROBANTES INGRESO');

DROP TABLE IF EXISTS aux_docs;
CREATE TEMP TABLE aux_docs AS
select
	t.id_administracion_sucursales,
	t.nom_suc,
	d.codigo_tipo,
    d.fecha::DATE AS fecha,
	d.ndocumento,
    t.suma
from
	aux_parametros_reporte a,
	tipo_docs t,
	documentos d
WHERE
	d.fecha::date = a.fecha_corte::DATE and
	d.estado AND
	d.codigo_tipo = t.codigo_tipo ; -- Solo documentos de la sucursal seleccionada
    
    
DROP TABLE IF EXISTS aux_facs_credito;
CREATE TEMP TABLE aux_facs_credito AS
SELECT
    l.ndocumento,
    l.fecha::DATE AS fecha,
    SUM(l.debe) AS debe,
    SUM(l.haber) AS haber
FROM
    aux_docs a,
    cuentas c, 
    libro_auxiliar l
WHERE
    a.ndocumento = l.ndocumento AND    
    c.id_cta=l.id_cta AND
	l.debe != 0 AND
    c.char_cta LIKE '1305%' -- Se pone like para que tenga en cuenta todas las facturas incluidas plataformas web Feb 27 2021
GROUP BY
    l.ndocumento,
    l.fecha::DATE;


DROP TABLE IF EXISTS aux_abonos_facs_credito;
CREATE TEMP TABLE aux_abonos_facs_credito AS
SELECT
	--c.nfactura,
	c.ncomprobante,
	d.fecha::DATE AS fecha_comprobante,
	-1*SUM(COALESCE(c.cargo_comprobante,0)-(COALESCE(c.abono_comprobante,0)+COALESCE(c.dcto_comprobante,0))) AS abono_comprobante
FROM
	aux_docs a,
	tipo_doc_comprobante td,
	documentos d,
	documentos d2,
	cartera c
WHERE
	c.ncomprobante = a.ndocumento AND
	c.nfactura = d2.ndocumento AND
	d2.estado AND
	c.ncomprobante = d.ndocumento AND
	a.fecha::DATE = d.fecha::DATE AND
	--CASE WHEN d.codigo_tipo IN (SELECT codigo_tipo FROM tipo_doc_devoluciones) THEN TRUE ELSE a.fecha::DATE = d2.fecha::DATE END AND Junio 5 2025: quito 
	-- este filtro porque no entiendo para que es y esta causando diferencia para la fecha 2025-06-04 en la principal
	d.codigo_tipo = td.codigo_tipo AND
	d.estado
GROUP BY
	--c.nfactura,
	c.ncomprobante,
	d.fecha;
	
-- Enero 17 de 2025
-- aqui se marcan los documentos que se pueden borrar: los que solo son a credito, los que tienen forma de pago en efectivo en la fecha del reporte no se pueden borrar asi
-- afecten documentos de fechas anteriores, ex DW-1518
DROP TABLE IF EXISTS aux_docs_no_borrar;
CREATE TEMP TABLE aux_docs_no_borrar as
select distinct
	a.ndocumento,
	l.id_cta
from
	aux_docs a,
	libro_auxiliar l,
	cuentas cu
where
	a.ndocumento = l.ndocumento and
	l.id_cta = cu.id_cta and
	 (cu.char_cta like '11%' OR
	  cu.char_cta like '28050502%' OR
	  cu.char_cta like '28050504%' OR
	  cu.char_cta like '2810%');


DELETE FROM 
	aux_docs AS a
USING 
	documentos d,
	documentos d2,
	tipo_doc_comprobante td,
	cartera c
where
	a.ndocumento not in (select ndocumento from aux_docs_no_borrar ) and -- Enero 17 de 2025
	a.ndocumento = d.ndocumento AND
	d.codigo_tipo = td.codigo_tipo AND
	a.ndocumento = c.ncomprobante AND
	c.nfactura = d2.ndocumento AND
	d2.estado AND
	d2.fecha::DATE != a.fecha::DATE;
	
DROP TABLE IF EXISTS aux_abonos_ci_tarjeta;
CREATE TEMP TABLE aux_abonos_ci_tarjeta AS
SELECT
    a.fecha_comprobante,
    --SUM(a.abono_comprobante) AS valor
	SUM(t.valor) AS valor
FROM
    tarjetas t,
    tcredito tc,
    aux_abonos_facs_credito a,
    cuentas c
WHERE
    t.ndocumento=a.ncomprobante AND
    t.id_tcredito = tc.id_tcredito AND
    tc.tipo NOT IN ('TR') AND --estas tarjetas se usan para pagos con nequi y demás ...se tratan como consignaciones y tienen apartado propio
    t.id_cta = c.id_cta AND
    c.char_cta NOT IN ('28050504')	-- no se incluyen tarjetas regalo porque tienen seccion aparte mas abajo
GROUP BY
    a.fecha_comprobante;


DROP TABLE IF EXISTS aux_abonos_ci_consignaciones;
CREATE TEMP TABLE aux_abonos_ci_consignaciones AS
SELECT
	COALESCE(foo.fecha_comprobante,foo2.fecha_comprobante) AS fecha_comprobante,
	COALESCE(foo.valor,0) + COALESCE(foo2.valor,0) AS valor
FROM	
	(SELECT
		a.fecha_comprobante,
		--SUM(a.abono_comprobante) AS valor
	 	SUM(t.valor) AS valor
	FROM
		tarjetas t,
		tcredito tc,
		aux_abonos_facs_credito a,
		cuentas c
	WHERE
		t.ndocumento=a.ncomprobante AND
		t.id_tcredito = tc.id_tcredito AND
		tc.tipo = 'TR' AND --estas tarjetas se usan para pagos con nequi y demás ...se tratan como consignaciones
		t.id_cta = c.id_cta AND
		c.char_cta NOT IN ('28050504')	-- no se incluyen tarjetas regalo porque tienen seccion aparte mas abajo
	GROUP BY
		a.fecha_comprobante) AS foo
FULL OUTER JOIN
	(SELECT
		a.fecha_comprobante,
		SUM(co.valor) AS valor
	FROM
		consignaciones co,
		aux_abonos_facs_credito a
	WHERE
		co.ndocumento=a.ncomprobante
	GROUP BY
		a.fecha_comprobante) AS foo2
ON
	foo.fecha_comprobante = foo2.fecha_comprobante;
	
	
--Medios de pago de los comprobantes de ingreso
DROP TABLE IF EXISTS aux_medios_pago_ci;
CREATE TEMP TABLE aux_medios_pago_ci AS
SELECT
    foo.fecha_comprobante,
    COALESCE(foo.efectivo,0) AS efectivo,
    COALESCE(cit.valor,0) AS tarjeta,
    COALESCE(foo.tregalo,0) AS tregalo,
    COALESCE(foo.sodexo,0) AS sodexo,
    COALESCE(foo.bigpass,0) AS bigpass,
    COALESCE(cic.valor,0) AS consignaciones
FROM
    (SELECT
        a.fecha_comprobante,
        SUM(CASE WHEN c.char_cta = '11053501' THEN a.abono_comprobante ELSE 0 END) AS efectivo,
        SUM(CASE WHEN c.char_cta = '28050504' THEN a.abono_comprobante ELSE 0 END) AS tregalo,
        SUM(CASE WHEN c.char_cta = '11052001' THEN a.abono_comprobante ELSE 0 END) AS sodexo,
        SUM(CASE WHEN c.char_cta = '11052501' THEN a.abono_comprobante ELSE 0 END) AS bigpass
    FROM
        libro_auxiliar l,
        cuentas c,
        aux_abonos_facs_credito a
    WHERE
        a.ncomprobante = l.ndocumento AND
        c.id_cta=l.id_cta AND
        l.debe != 0
    GROUP BY
        a.fecha_comprobante) AS foo
LEFT OUTER JOIN
    aux_abonos_ci_tarjeta cit
ON
    foo.fecha_comprobante = cit.fecha_comprobante
LEFT OUTER JOIN
    aux_abonos_ci_consignaciones cic
ON
    foo.fecha_comprobante = cic.fecha_comprobante;
    
    
--
DROP TABLE IF EXISTS aux_resultado_repo_local;
CREATE TEMP TABLE aux_resultado_repo_local AS
SELECT
    1::INTEGER AS id,
	a.nom_suc,
	'EFECTIVO'::VARCHAR AS nombre,
	COALESCE(efectivo.valor,0)/*+COALESCE(aci.efectivo,0)*/ AS valor,
	a.id_administracion_sucursales
FROM    
    (SELECT DISTINCT fecha, nom_suc, id_administracion_sucursales FROM aux_docs) a
LEFT OUTER JOIN
    (SELECT
        l.fecha::DATE AS fecha,	 	
        sum(debe)-sum(haber) AS valor
    FROM
        aux_docs a,
        libro_auxiliar l,
        cuentas c
    WHERE
        a.ndocumento = l.ndocumento AND
        c.id_cta=l.id_cta AND
        c.char_cta IN ('11053501','530535') --efectivo, descuentos
    GROUP BY 
        l.fecha::DATE) AS efectivo
ON
    a.fecha = efectivo.fecha
/*LEFT OUTER JOIN
    aux_medios_pago_ci aci
ON
    a.fecha = aci.fecha_comprobante*/
UNION
SELECT
    2::INTEGER AS id,
	a.nom_suc,
	'TARJETAS'::VARCHAR AS nombre,
	COALESCE(tarjetas.valor,0)/*+COALESCE(aci.tarjeta,0)*/ AS valor,
	a.id_administracion_sucursales
FROM    
    (SELECT DISTINCT fecha, nom_suc, id_administracion_sucursales FROM aux_docs) a
LEFT OUTER JOIN
    (SELECT
        a.fecha,	 	
        SUM(CASE WHEN a.suma THEN t.valor ELSE t.valor*-1 END) AS valor
    FROM
        tarjetas t,     
        tcredito tc,
        aux_docs a,
        cuentas c
    WHERE
        t.id_tcredito = tc.id_tcredito AND
        tc.tipo NOT IN ('TR') AND --estas tarjetas se usan para pagos con nequi y demás ...se tratan como consignaciones y tienes apartado propio
        t.ndocumento=a.ndocumento AND
        t.id_cta = c.id_cta AND
        c.char_cta NOT IN ('28050504')	-- no se incluyen tarjetas regalo porque tienen seccion aparte mas abajo
    GROUP BY
        a.fecha) AS tarjetas
ON
    a.fecha = tarjetas.fecha
/*LEFT OUTER JOIN
    aux_medios_pago_ci aci
ON
    a.fecha = aci.fecha_comprobante*/
UNION
SELECT
    3::INTEGER AS id,
	a.nom_suc,
	'BONOS REGALO'::VARCHAR AS nombre,
	COALESCE(tregalo.valor,0)/*+COALESCE(aci.tregalo,0)*/ AS valor,
	a.id_administracion_sucursales
FROM    
    (SELECT DISTINCT fecha, nom_suc, id_administracion_sucursales FROM aux_docs) a
LEFT OUTER JOIN
    (SELECT
        l.fecha::DATE AS fecha,	 	
        sum(debe)-sum(haber) AS valor
    FROM
        aux_docs a,
        libro_auxiliar l,
        cuentas c
    WHERE
        a.ndocumento = l.ndocumento AND	 	
        c.id_cta=l.id_cta AND
        c.char_cta ='28050504'
    GROUP BY 
        l.fecha::DATE) AS tregalo
ON
    a.fecha = tregalo.fecha
/*LEFT OUTER JOIN
    aux_medios_pago_ci aci
ON
    a.fecha = aci.fecha_comprobante*/
UNION
SELECT
    4::INTEGER AS id,
	a.nom_suc,
	'CHEQUES SODEXO'::VARCHAR AS nombre,
	COALESCE(sodexo.valor,0)+COALESCE(aci.sodexo,0) AS valor,
	a.id_administracion_sucursales
FROM    
    (SELECT DISTINCT fecha, nom_suc, id_administracion_sucursales FROM aux_docs) a
LEFT OUTER JOIN
    (SELECT
        l.fecha::DATE AS fecha,	 	
        sum(debe)-sum(haber) AS valor
    FROM
        aux_docs a,
        libro_auxiliar l,
        cuentas c
    WHERE
        a.ndocumento = l.ndocumento AND
        c.id_cta=l.id_cta AND
        c.char_cta ='11052001'
    GROUP BY 
        l.fecha::DATE) AS sodexo
ON
    a.fecha = sodexo.fecha
LEFT OUTER JOIN
    aux_medios_pago_ci aci
ON
    a.fecha = aci.fecha_comprobante
UNION
SELECT
    5::INTEGER AS id,
	a.nom_suc,
	'CHEQUES BIGPASS'::VARCHAR AS nombre,
	COALESCE(bigpass.valor,0)+COALESCE(aci.bigpass,0) AS valor,
	a.id_administracion_sucursales
FROM    
    (SELECT DISTINCT fecha, nom_suc, id_administracion_sucursales FROM aux_docs) a
LEFT OUTER JOIN
    (SELECT
        l.fecha::DATE AS fecha,	 	
        sum(debe)-sum(haber) AS valor
    FROM
        aux_docs a,
        libro_auxiliar l,
        cuentas c
    WHERE
        a.ndocumento = l.ndocumento AND
        c.id_cta=l.id_cta AND
        c.char_cta ='11052501'
    GROUP BY 
        l.fecha::DATE) AS bigpass
ON
    a.fecha = bigpass.fecha
LEFT OUTER JOIN
    aux_medios_pago_ci aci
ON
    a.fecha = aci.fecha_comprobante
UNION
SELECT
    6::INTEGER AS id,
	a.nom_suc,
	'VENTAS CREDITO'::VARCHAR AS nombre,
	COALESCE(fcredito.valor,0)-COALESCE(abonos.valor,0) AS valor,
	a.id_administracion_sucursales
FROM    
    (SELECT DISTINCT fecha, nom_suc, id_administracion_sucursales FROM aux_docs) a
LEFT OUTER JOIN
     (SELECT
        a.fecha::DATE AS fecha,	 	
        sum(a.debe) AS valor
    FROM
        aux_facs_credito a
	GROUP BY
		a.fecha::DATE) AS fcredito
ON
    a.fecha = fcredito.fecha
LEFT OUTER JOIN
	(SELECT
        abonos.fecha_comprobante::DATE AS fecha,	 	
    	sum(abonos.abono_comprobante) AS valor
    FROM
	 	aux_abonos_facs_credito abonos
	GROUP BY
		abonos.fecha_comprobante::DATE) AS abonos
ON
    a.fecha = abonos.fecha
UNION
SELECT
    7::INTEGER AS id,
	a.nom_suc,
	'ANTICIPOS'::VARCHAR AS nombre,
	COALESCE(anticipos.valor,0) AS valor,
	a.id_administracion_sucursales
FROM    
    (SELECT DISTINCT fecha, nom_suc, id_administracion_sucursales FROM aux_docs) a
LEFT OUTER JOIN
     (SELECT
        l.fecha::DATE AS fecha,
        sum(debe)-sum(haber) AS valor
    FROM
        aux_docs a,
        libro_auxiliar l,
        cuentas c
    WHERE
        a.ndocumento = l.ndocumento AND
        c.id_cta=l.id_cta AND
        c.char_cta in ('28050502')
    GROUP BY 
        l.fecha::DATE) AS anticipos
ON
    a.fecha = anticipos.fecha
LEFT OUTER JOIN
    aux_medios_pago_ci aci
ON
    a.fecha = aci.fecha_comprobante
UNION
SELECT
    8::INTEGER AS id,
	a.nom_suc,
	'CONSIGNACIONES'::VARCHAR AS nombre,
	COALESCE(consignaciones.valor,0)+COALESCE(aci.consignaciones,0)+COALESCE(consignacionesfactura.valor,0) AS valor,
	a.id_administracion_sucursales
FROM    
    (SELECT DISTINCT fecha, nom_suc, id_administracion_sucursales FROM aux_docs) a
LEFT OUTER JOIN
     (
		SELECT
			a.fecha,			
			SUM(CASE WHEN a.suma THEN t.valor ELSE t.valor*-1 END) AS valor
		FROM
			tarjetas t,
			tcredito tc,
			aux_docs a,
			cuentas c
		WHERE
			t.ndocumento=a.ndocumento AND
			t.id_tcredito = tc.id_tcredito AND
		 	a.codigo_tipo NOT IN (SELECT codigo_tipo FROM tipo_doc_abonos_cartera) AND
			tc.tipo = 'TR' AND --estas tarjetas se usan para pagos con nequi y demás ...se tratan como consignaciones
			t.id_cta = c.id_cta AND
			c.char_cta NOT IN ('28050504')	-- no se incluyen tarjetas regalo porque tienen seccion aparte mas abajo
		GROUP BY
			a.fecha	
	) AS consignaciones
ON
    a.fecha = consignaciones.fecha
LEFT OUTER JOIN
    aux_medios_pago_ci aci
ON
    a.fecha = aci.fecha_comprobante
left outer join 
	(SELECT
		a.fecha,
		SUM(co.valor) AS valor
    FROM
        aux_docs a,
		tipo_docs_solo_facturacion sf,
		consignaciones co,
        cuentas c
    WHERE
		a.ndocumento = co.ndocumento AND
		a.codigo_tipo = sf.codigo_tipo and
		a.suma AND
        c.id_cta=co.id_cta AND
        (c.char_cta like ('1110%') or
		c.char_cta like ('1120%'))
    GROUP BY 
        a.fecha::DATE) AS consignacionesfactura
on 
	a.fecha = consignacionesfactura.fecha;
	
--

SELECT
	id,
	nom_suc,
	nombre,
	valor,
	id_administracion_sucursales
FROM
	aux_resultado_repo_remoto
UNION ALL
SELECT
	id,
	nom_suc,
	nombre,
	valor,
	id_administracion_sucursales
FROM
	aux_resultado_repo_local
ORDER BY
	nombre;