--JBSEL0062
drop table if exists aux_facturas_pendientes;
create temp table aux_facturas_pendientes as
WITH tercero_param AS (
    SELECT ?::BIGINT AS id_tercero
),
v_base AS (
    SELECT 
        l.ndocumento,
        ROUND(SUM(l.debe)::NUMERIC, 2) AS vlor
    FROM 
    	libro_auxiliar l
    join
    	cuentas cta 
    ON 
    	cta.id_cta = l.id_cta
       	AND cta.char_cta LIKE '1435%'
   JOIN 
   		tercero_param t 
    ON 
    	l.id_tercero = t.id_tercero
    WHERE 
    	l.debe > 0
    GROUP BY 
    	l.ndocumento
),
base AS (
    SELECT
        d.fecha,
        d.codigo_tipo,
        c.dcredito,
        c.idtercero,
        d.codigo_tipo || '-' || d.numero::BIGINT ||
            CASE 
                WHEN i.ex_documento IS NOT NULL 
                     AND btrim(i.ex_documento) <> '' 
                THEN ' / ' || i.ex_documento 
                ELSE '' 
            END AS numero,
        c.nfactura,
        v_base.vlor,
        c.total_factura,
        ac.char_cta,
        ac.id_cta,
        d.ndocumento
    FROM cartera c
    JOIN tercero_param t ON c.idtercero = t.id_tercero
    JOIN documentos d ON d.ndocumento = c.nfactura AND d.estado = TRUE
    JOIN info_documento i ON i.ndocumento = d.ndocumento
    JOIN cuentas ac ON ac.id_cta = c.id_cta AND ac.char_cta ILIKE '2205%'
    left JOIN v_base ON v_base.ndocumento = c.nfactura
    WHERE c.total_factura > 0
)

SELECT
    fecha,
    codigo_tipo,
    dcredito,
    idtercero,
    numero,
    nfactura,
    vlor AS vfactura,
    SUM(total_factura) AS tfactura,
    char_cta,
    id_cta,
    ndocumento
FROM base
GROUP BY
    fecha,
    codigo_tipo,
    dcredito,
    idtercero,
    numero,
    nfactura,
    vlor,
    char_cta,
    id_cta,
    ndocumento;

drop table if exists aux_cuentas_iva;
create temp table aux_cuentas_iva as
select
	cu.id_cta
from
	cuentas cu
where
	cu.tipo = false and
	cu.char_cta like '240801%';

drop table if exists aux_valor_iva_de_facturas;
create temp table aux_valor_iva_de_facturas as
select
	la.ndocumento,
	sum(la.debe) as valor_iva
from
	libro_auxiliar la
where
	la.id_cta in (select cu.id_cta from aux_cuentas_iva cu) and	
	la.ndocumento in (select distinct ndocumento from aux_facturas_pendientes)
group by
	la.ndocumento;

select
	--'nada'::text as nada,
	false as seleccion,
	fecha,
	dcredito,
	vencimiento,
	numero,
	saldo,
	0 as abono,
	0 as pdescuento,
	0 as valor_descuento,
	0 as total_pagar,
	0 as saldo_factura,
	ex_documento as fac_proveedor,
	ndocumento,
	vfactura,
	0 as valor_pago,
	char_cta,
	id_cta,
	case when foo.codigo_tipo = '1C' then round((saldo/1.19)::numeric,2) else round(vfactura::numeric,2) end as valor_base,
	0 as contador_factura,
	case when foo.codigo_tipo = '1C' then saldo-round((saldo/1.19)::numeric,2) else round((valor_iva)::numeric,2) end as valor_iva
FROM
	(select
		foo.codigo_tipo,
		CAST(fecha AS date) AS fecha,
		CAST(textcat(text(foo.dcredito), text(' dias')) AS text) AS dcredito,
		CAST(fecha + CAST(textcat(text(dcredito), text(' days')) as interval) AS date) AS vencimiento,
		foo.numero,
		saldo,
		' '||if.ex_documento as ex_documento,
		foo.ndocumento,
		vfactura,
		char_cta,
		id_cta,
		foo.valor_iva
	FROM
		(select
			c.codigo_tipo,
			c.fecha,
			c.dcredito,
			c.numero,
			c.nfactura,
			c.vfactura,
			c.tfactura,
			c.tfactura+COALESCE(co.vcomprobante,0) AS saldo,
			c.char_cta,
			c.id_cta,
			c.ndocumento,
			coalesce(iva.valor_iva,0) as valor_iva
		from					
			aux_facturas_pendientes AS c
		LEFT OUTER JOIN
			(SELECT
				c.nfactura,
			 	c.idtercero,
				SUM(COALESCE(c.cargo_comprobante,0))-(SUM(COALESCE(c.abono_comprobante,0))+SUM(COALESCE(c.dcto_comprobante,0))) AS vcomprobante
			FROM
				cartera c,
				cuentas cu,
				documentos d
			where
				c.id_cta = cu.id_cta and
				cu.char_cta like '2205%' and
				c.ncomprobante=d.ndocumento AND
				d.estado='true'
			GROUP BY
				c.nfactura,
				c.idtercero) AS co
		ON
			co.nfactura=c.nfactura  AND
			co.idtercero = c.idtercero
		left join
			aux_valor_iva_de_facturas iva
		on
			c.nfactura = iva.ndocumento) AS foo
	LEFT OUTER JOIN
		info_documento if
	ON
		if.ndocumento=foo.ndocumento 
	ORDER BY
		fecha,numero) as foo
WHERE
	foo.saldo!=0;

