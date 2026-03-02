DROP TABLE IF EXISTS cupotercero;
DROP TABLE IF EXISTS saldotercero;

CREATE TEMP TABLE cupotercero AS
SELECT 
	i.id,
	COALESCE(i.cupomaximo,0) AS cupomaximo,
	i.estado,
	cu.id_cta,
	foo.char_cta,
	case when p.id is not null then 1 else 0 end as empleado -- 1 si es empleado 0 si no lo es
from
	(select
		trim('?'::text) as id,
		trim('?'::text) as char_cta) as foo
inner join
	cuentas cu
on
	foo.char_cta = cu.char_cta
inner join
	info_credito i
on	
	i.id::text = foo.id
left join
	propiedad_tercero p
on
	i.id = p.id and 
	p.codigo = '12';
	
CREATE TEMP TABLE saldotercero AS
SELECT
        COALESCE(SUM(saldo),0) AS saldo
FROM
        (SELECT
                c.tfactura+COALESCE(co.cargos,0)-COALESCE(co.vcomprobante,0) AS saldo
        FROM
                (SELECT
					d.fecha,
					d.codigo_tipo||d.numero AS numero,
					c.idtercero,
					c.nfactura,
					c.dcredito,
					SUM(c.neto_factura) AS vfactura,
					SUM(c.total_factura) AS tfactura,
					ac.char_cta,
					ac.id_cta,
					d.ndocumento
                FROM
                    cartera c,
					cuentas ac,
                    documentos d,
                    cupotercero
                where
                	--cupotercero.char_cta = '13050501' and
                	cupotercero.char_cta = ac.char_cta and
					ac.char_cta ~ '130505.' AND
					ac.id_cta=c.id_cta AND
                    d.ndocumento=c.nfactura AND
					c.idtercero=cupotercero.id AND
                    d.estado='true' AND
					c.movimiento=true AND
                    c.total_factura>0
                GROUP BY
					d.fecha,
					d.codigo_tipo,
					d.numero,
					d.ndocumento,
					c.idtercero,
                    c.nfactura,
                    c.dcredito,
					ac.id_cta,
					ac.char_cta) AS c
        LEFT OUTER JOIN
                (SELECT
					c.idtercero,
                    c.nfactura,
                    SUM(c.abono_comprobante)+SUM(c.dcto_comprobante) AS vcomprobante,
					SUM(c.cargo_comprobante) AS cargos
                FROM
                        cartera c,
                        documentos d
                where
                		c.id_cta = (select id_cta from cupotercero limit 1) and
                		d.fecha::date <= current_date and
                        c.ncomprobante=d.ndocumento AND
                        d.estado='true'
                GROUP BY
					c.idtercero,
                    c.nfactura) AS co
        ON
			co.idtercero=c.idtercero AND
            co.nfactura=c.nfactura) AS foo
WHERE
	foo.saldo>0;
                
--
                
SELECT 
	(c.cupomaximo - s.saldo) AS saldo
FROM
	saldotercero s,
	cupotercero c;
