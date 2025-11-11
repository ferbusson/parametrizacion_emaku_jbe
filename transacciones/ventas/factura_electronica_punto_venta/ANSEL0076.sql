DROP TABLE IF EXISTS nseparado;
CREATE TEMP TABLE nseparado AS
SELECT
    ds2.codigo_tipo AS cseparado,
    ds3.codigo_tipo AS cabono,
    d.ndocumento as separado,
    t.id as tercero
FROM
    documentos d,
    tercero_def t,
    documentos_sucursales ds,
    documentos_sucursales ds2,
    documentos_standar dst2,
    documentos_sucursales ds3,
    documentos_standar dst3
WHERE
    d.codigo_tipo = ds.codigo_tipo AND
    ds.id_administracion_sucursales = ds2.id_administracion_sucursales AND
    dst2.id_documento = ds2.id_documento AND
    dst2.nombre IN ('SEPARADOS') AND
    ds.id_administracion_sucursales = ds3.id_administracion_sucursales AND
    dst3.id_documento = ds3.id_documento AND
    dst3.nombre IN ('ABONOS SEPARADOS') AND
    d.ndocumento = '?' AND
    d.ndocumento = t.ndocumento;
    
-----------------------------------------------------
SELECT
    fecha,
    dcredito,
    vencimiento,
    numero,
    saldo,
    saldo,
    0,
    0,
    0,
    0,
    0,
    ex_documento,
    0,
    0,
    0,
    ndocumento,
    vfactura,
    0,
    char_cta,
    id_cta
FROM
  (SELECT
    fecha,
    dcredito,
    vencimiento,
    numero,
    saldo,
    ex_documento,
    ndocumento,
    vfactura,
    char_cta,
    id_cta
FROM
    (SELECT
        CAST(fecha AS date) AS fecha,
        CAST(textcat(text(foo.dcredito), text(' dias')) AS text) AS dcredito,
        CAST(fecha + CAST(textcat(text(dcredito), text(' days')) as interval) AS date) AS vencimiento,
        foo.numero,
        saldo,
        ' '||if.ex_documento as ex_documento,
        foo.ndocumento,
        vfactura,
        char_cta,
        id_cta
    FROM
    (SELECT 
        c.fecha,
        c.dcredito,
        c.numero,
        c.nfactura,
        c.vfactura,
        c.tfactura,
        c.tfactura+COALESCE(co.vcomprobante,0) AS saldo,
        c.char_cta,
        c.id_cta,
        c.ndocumento
    FROM
        (SELECT
            d.fecha,
            c.dcredito,
            d.codigo_tipo||d.numero AS numero,
            c.nfactura,
            SUM(c.neto_factura) AS vfactura,
            SUM(c.total_factura) AS tfactura,
            ac.char_cta,
            ac.id_cta,
            d.ndocumento
        FROM
            cartera c,
            documentos d,
            cuentas ac,
            nseparado ns,
            info_documento id
        WHERE
            c.idtercero=ns.tercero AND
            ac.char_cta ilike '2%' AND
            (d.ndocumento = ns.separado OR
            id.rf_documento = ns.separado) AND
            id.ndocumento = d.ndocumento AND
            d.ndocumento = c.nfactura AND
            ac.id_cta = c.id_cta AND
            d.estado = 'true' AND
            c.total_factura>0
        GROUP BY
            d.fecha,
            c.nfactura,
            c.dcredito, 
            d.codigo_tipo,
            d.numero,
            c.nfactura,
            c.dcredito,
            ac.char_cta,
            ac.id_cta,
            d.ndocumento) as c
        LEFT OUTER JOIN
            (SELECT
                c.nfactura,
                SUM(COALESCE(c.cargo_comprobante,0))-(SUM(COALESCE(c.abono_comprobante,0))+SUM(COALESCE(c.dcto_comprobante,0))) AS vcomprobante
            FROM
                cartera c,
                documentos d
            WHERE
                c.ncomprobante=d.ndocumento AND
                d.estado='true'
            GROUP BY
                c.nfactura) AS co
        ON
            co.nfactura=c.nfactura) AS foo
LEFT OUTER JOIN
    info_documento if
ON
    if.ndocumento=foo.ndocumento 
ORDER BY
    fecha,numero) as foo
WHERE
    foo.saldo!=0
UNION
SELECT
    fecha,
    dcredito,
    vencimiento,
    numero,
    saldo,
    ex_documento,
    ndocumento,
    vfactura,
    char_cta,
    id_cta
FROM
    (SELECT
        CAST(fecha AS date) AS fecha,
        CAST(textcat(text(foo.dcredito), text(' dias')) AS text) AS dcredito,
        CAST(fecha + CAST(textcat(text(dcredito), text(' days')) as interval) AS date) AS vencimiento,
        foo.numero,
        saldo,
        ' '||if.ex_documento as ex_documento,
        foo.ndocumento,
        vfactura,
        char_cta,
        id_cta
    FROM
        (SELECT
            c.fecha,
            c.dcredito,
            c.numero,
            c.nfactura,
            c.vfactura,
            c.tfactura,
            c.tfactura+COALESCE(co.vcomprobante,0) AS saldo,
            c.char_cta,
            c.id_cta,
            c.ndocumento
        FROM
            (SELECT
                D.fecha,
                c.dcredito,
                d.codigo_tipo||d.numero AS numero,
                c.nfactura,
                SUM(c.neto_factura) AS vfactura,
                SUM(c.total_factura) AS tfactura,
                ac.char_cta,
                ac.id_cta,
                d.ndocumento
            FROM
                cartera c,
                documentos d,
                cuentas ac,
                nseparado ns,
                info_documento id
            WHERE
                c.idtercero=ns.tercero AND
                ac.char_cta ilike '2%' AND
                d.ndocumento=c.nfactura AND
                (d.codigo_tipo = ns.cseparado OR
                 d.codigo_tipo = ns.cabono) AND 
                ac.id_cta=c.id_cta AND
                id.rf_documento = NULL AND
                id.ndocumento = d.ndocumento AND
                d.estado='true' AND
                c.total_factura>0
            GROUP BY
                d.fecha,
                c.nfactura,
                c.dcredito, 
                d.codigo_tipo,
                d.numero,
                c.nfactura,
                c.dcredito,
                ac.char_cta,
                ac.id_cta,
                d.ndocumento) AS c
        LEFT OUTER JOIN
            (SELECT
                c.nfactura,
                SUM(COALESCE(c.cargo_comprobante,0))-(SUM(COALESCE(c.abono_comprobante,0))+SUM(COALESCE(c.dcto_comprobante,0))) AS vcomprobante
            FROM
                cartera c,
                documentos d
            WHERE
                c.ncomprobante=d.ndocumento AND
                d.estado='true'
            GROUP BY
                c.nfactura) AS co
        ON
            co.nfactura=c.nfactura) AS foo
    LEFT OUTER JOIN
        info_documento if
    ON
        if.ndocumento=foo.ndocumento 
    ORDER BY
        fecha,numero) as foo
WHERE
    foo.saldo!=0) as fs
ORDER BY fecha;