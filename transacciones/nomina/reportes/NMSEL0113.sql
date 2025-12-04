DROP TABLE IF EXISTS aux_parametros_repo;
CREATE TEMP TABLE aux_parametros_repo AS 
SELECT
    '?'::DATE AS fechai,
    '?'::DATE AS fechaf,
    '?'::VARCHAR(14) AS id_char;

   -- nominas que hacen parte del rango de fechas solicitado
DROP TABLE IF EXISTS nm;
CREATE temp TABLE nm AS 
SELECT distinct
    d.ndocumento,
    cn.id_tercero
FROM 
    documentos d,
    aux_parametros_repo a,
    causacion_nomina cn
WHERE 
    d.codigo_tipo='NM' AND 
    d.ndocumento = cn.ndocumento AND
    CASE when a.id_char IS NULL OR TRIM(a.id_char) = '' THEN TRUE ELSE cn.id_tercero = (SELECT id FROM general where id_char = a.id_char) END AND
    d.estado AND
    d.fecha::DATE BETWEEN a.fechai AND fechaf;

--

SELECT
    fecha,
    UPPER(division) AS division,
    numero_nomina,
    foo.id_char,
    UPPER(nombre) AS nombre,
    dias,
    UPPER(descripcion) AS descripcion,
    devengado,
    deducido,
    'http://localhost:9152/emaku/qrNomina/'||cf.ndocumento||'-'||foo.id_char||'.jpg' as qr,
    cf.cufe AS cune,
    apr.fechai||' a '||apr.fechaf as periodo,
    cf.fecha_procesamiento,
    foo.ciudad,
    foo.condiciones_pago,
    numero_nomina||'-'||foo.id_char as criterio_agrupacion,
    cf.documento_ne
from
	aux_parametros_repo apr,
    (SELECT
        d.ndocumento,
        CAST(d.fecha AS date) AS fecha,
        dn.descripcion as division,
        tipo_movimiento,
        c.id_concepto_causacion,
        g.id_char,
        d.codigo_tipo||'-'||d.numero::BIGINT AS numero_nomina,
        upper(trim(COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,''))) AS nombre,
        dias,
        trim(case when c.descripcion ilike 'SALARIO%' then 'SALARIO' 
        	when c.descripcion ilike 'AUXILI%TRANSPORT%' then 'AUXILIO DE TRANSPORTE' else
        	replace(replace(replace(c.descripcion,' VTAS',''),' VENTAS',''),' ADMIN','') end) as descripcion,
        cn.valor AS devengado,
        0 as deducido,
        CASE -- se hace el case when para poder ordenar los conceptos segun requerimiento de la cali, el id_movimiento_nomina da el indice que permite ordenar los conceptos
            WHEN m.id_movimiento_nomina = 1 AND c.descripcion ILIKE '%SALARIO%' THEN 0 
            WHEN m.id_movimiento_nomina = 1 AND c.descripcion NOT ILIKE '%SALARIO%' THEN 1
            WHEN m.id_movimiento_nomina = 2 THEN 5 
            WHEN m.id_movimiento_nomina = 3 THEN 13
            WHEN m.id_movimiento_nomina = 4 THEN 14
            WHEN m.id_movimiento_nomina = 5 THEN 2 
            WHEN m.id_movimiento_nomina = 6 THEN 6
            WHEN m.id_movimiento_nomina = 7 THEN 3 
            WHEN m.id_movimiento_nomina = 8 THEN 7
            WHEN m.id_movimiento_nomina = 9 THEN 19
            ELSE 99 END AS id_movimiento_nomina,
        -- para obtener la ciudad tenemos en cuenta la descripcion de la division
        case when dn.descripcion ilike '%IPIA%' or dn.descripcion ilike '%GRAN%PLAZA%' then 'IPIALES' else 'PASTO' end as ciudad,
        fpn.descripcion||' / '||cb.cuenta_bancaria||' / '||icn.fecha_pago as condiciones_pago
    FROM
        documentos d,                
        concepto_causacion c,
        general g,
        movimientos_nomina m,
        division_nomina dn,
        nm,
        causacion_nomina cn
    left outer join
    	info_causacion_nomina icn
    on
    	icn.ndocumento = cn.ndocumento and
    	icn.id_division_nomina = cn.id_division_nomina
    left outer join
    	formas_pago_nomina fpn
    on
    	icn.id_forma_pago_nomina = fpn.id_forma_pago_nomina
    left outer join
    	(select distinct on (cb.id)
    		cb.id,
    		b.nombre||' '||cb.cuenta as cuenta_bancaria 
    	from
    		cuentas_bancarias cb,
    		bancos b
    	where
	    	cb.banco = b.banco
    	order by
    		cb.id,
    		cb.id_cuenta_bancaria desc) cb
    on
    	cn.id_tercero = cb.id
    where
    	cn.ndocumento = icn.ndocumento and
        nm.ndocumento=d.ndocumento AND
        d.ndocumento=cn.ndocumento AND
        cn.id_concepto_causacion=c.id_concepto_causacion AND        
        (c.id_movimiento_nomina=1 or 
        c.id_movimiento_nomina=5 or
        c.id_movimiento_nomina=7 or
        c.id_movimiento_nomina=9) and
        dn.id_division_nomina=cn.id_division_nomina AND
        m.id_movimiento_nomina=c.id_movimiento_nomina AND
        g.id = cn.id_tercero AND
        cn.id_tercero = nm.id_tercero
    union
    SELECT
        d.ndocumento,
        CAST(d.fecha AS date) AS fecha,
        dn.descripcion as division,
        tipo_movimiento,
        c.id_concepto_causacion,
        g.id_char,
        d.codigo_tipo||'-'||d.numero::BIGINT AS numero_nomina,
        upper(trim(COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,''))) AS nombre,
        dias,
        trim(case when c.descripcion ilike 'SALARIO%' then 'SALARIO'
        	when c.descripcion ilike 'AUXILI%TRANSPORT%' then 'AUXILIO DE TRANSPORTE' else
        	replace(replace(replace(c.descripcion,' VTAS',''),' VENTAS',''),' ADMIN','') end) as descripcion,
        0 AS devengado,
        cn.valor as deducido,
        CASE -- se hace el case when para poder ordenar los conceptos segun requerimiento de la cali, el id_movimiento_nomina da el indice que permite ordenar los conceptos
            WHEN m.id_movimiento_nomina = 1 AND c.descripcion ILIKE '%SALARIO%' THEN 0 
            WHEN m.id_movimiento_nomina = 1 AND c.descripcion ILIKE '%HORA%' THEN 2 --horas extra
            WHEN m.id_movimiento_nomina = 2 THEN 3 --salud 
            WHEN m.id_movimiento_nomina = 3 THEN 13
            WHEN m.id_movimiento_nomina = 4 THEN 14
            WHEN m.id_movimiento_nomina = 6 THEN 6
            WHEN m.id_movimiento_nomina = 7 AND c.descripcion ILIKE '%aux%trans%' then 1 -- dev x valor auxilio transporte
            WHEN m.id_movimiento_nomina = 8 THEN 7
            WHEN m.id_movimiento_nomina = 9 THEN 19
            ELSE 99 END AS id_movimiento_nomina,
		        -- para obtener la ciudad tenemos en cuenta la descripcion de la division
        	case when dn.descripcion ilike '%IPIA%' or dn.descripcion ilike '%GRAN%PLAZA%' then 'IPIALES' else 'PASTO' end as ciudad,
		fpn.descripcion||' / '||cb.cuenta_bancaria||' / '||icn.fecha_pago as condiciones_pago        	
    FROM
        documentos d,
        concepto_causacion c,
        movimientos_nomina m,
        general g,
        division_nomina dn,
        --datos_division dd,
        nm,
        causacion_nomina cn
    left outer join
    	info_causacion_nomina icn
    on
    	icn.ndocumento = cn.ndocumento and
    	icn.id_division_nomina = cn.id_division_nomina
    left outer join
    	formas_pago_nomina fpn
    on
    	icn.id_forma_pago_nomina = fpn.id_forma_pago_nomina
   	left outer join
    	(select distinct on (cb.id)
    		cb.id,
    		b.nombre||' '||cb.cuenta as cuenta_bancaria 
    	from
    		cuentas_bancarias cb,
    		bancos b
    	where
	    	cb.banco = b.banco
    	order by
    		cb.id,
    		cb.id_cuenta_bancaria desc) cb
    on
    	cn.id_tercero = cb.id
    WHERE
        --dd.id_tercero=g.id AND
        dn.id_division_nomina=cn.id_division_nomina AND
        m.id_movimiento_nomina=c.id_movimiento_nomina AND
        g.id=cn.id_tercero AND
        d.ndocumento=cn.ndocumento AND
        cn.id_concepto_causacion=c.id_concepto_causacion AND
        nm.ndocumento=d.ndocumento AND
        (c.id_movimiento_nomina=2 or 
        c.id_movimiento_nomina=6 or
        c.id_movimiento_nomina=8) AND
        cn.id_tercero = nm.id_tercero) AS foo
LEFT OUTER JOIN         
    (SELECT DISTINCT ON(i.rf_documento)
        i.ndocumento,
        i.rf_documento,
        d.codigo_tipo||'-'||d.numero::BIGINT as documento_ne,
        c.cufe,
        c.docadq,
        ew.fecha as fecha_procesamiento
     FROM
        documentos d,
        general g,
        info_documento i,
        nm a,
        cufe_documentos c
     left outer join
        envio_webservice ew
     on
     	c.ndocumento = ew.ndocumento and
     	c.docadq = ew.id_char
     WHERE
        d.estado AND
        d.ndocumento = i.ndocumento AND
        c.docadq = g.id_char AND
        g.id = a.id_tercero AND
        c.ndocumento = i.ndocumento
    ORDER BY
        i.rf_documento,
        i.ndocumento DESC)  AS cf
ON
    cf.rf_documento = foo.ndocumento AND
    cf.docadq = foo.id_char
ORDER BY
    --fecha,
    numero_nomina,
    --id_char,
    nombre,
    id_movimiento_nomina,
    id_concepto_causacion,
    devengado desc,
    deducido desc;