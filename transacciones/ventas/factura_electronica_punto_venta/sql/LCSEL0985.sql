DROP TABLE IF EXISTS cupotercero;
CREATE TEMP TABLE cupotercero AS
SELECT 
	i.id,
	COALESCE(i.cupomaximo,0) AS cupomaximo,
	i.estado,
	foo.char_cta,
	i.diascredito,
	case when p.id is not null then 1 else 0 end as empleado -- 1 si es empleado 0 si no lo es
from
	(select
		trim('?'::text) as id,
		trim('?'::text) as char_cta) as foo
inner join
	info_credito i
on	
	i.id::text = foo.id
left join
	propiedad_tercero p
on
	i.id = p.id;/* and
	p.codigo = '12';*/

DROP TABLE IF EXISTS saldotercero;	
CREATE TEMP TABLE saldotercero AS
select
		foo.fecha_vencimiento,
		foo.empleado,
        COALESCE(SUM(saldo),0) AS saldo
FROM
        (select
        	c.fecha_vencimiento,
            c.tfactura+COALESCE(co.cargos,0)-COALESCE(co.vcomprobante,0) AS saldo,
            c.empleado
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
					d.ndocumento,
					cupotercero.empleado,
					d.fecha+ interval '1 day' * cupotercero.diascredito as fecha_vencimiento
	            FROM
	            	cartera c,
					cuentas ac,
	                documentos d,
	                cupotercero
	            where
	               	cupotercero.char_cta = '13050501' and
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
					ac.char_cta,
					cupotercero.diascredito,
					cupotercero.empleado) AS c
        LEFT OUTER JOIN
                (SELECT
					c.idtercero,
                    c.nfactura,
                    SUM(c.abono_comprobante)+SUM(c.dcto_comprobante) AS vcomprobante,
					SUM(c.cargo_comprobante) AS cargos
                FROM
                        cartera c,
                        documentos d
                WHERE
                	c.id_cta = (select id_cta from cuentas where char_cta = '13050501') and
                    c.ncomprobante=d.ndocumento and
                    d.fecha::date <= current_date and
                    d.estado='true'
                GROUP BY
					c.idtercero,
                    c.nfactura) AS co
        ON
				co.idtercero=c.idtercero AND
                co.nfactura=c.nfactura) AS foo
WHERE
	foo.saldo>0
group by
	foo.fecha_vencimiento,
	foo.empleado;
                
--
-- si la suma es mayor a cero significa que al menos una de las facturas esta vencida
select
	coalesce(sum(case when fecha_vencimiento::date < current_date and empleado = 1 then 1 else 0 end),0) as facturasvencidas 
from
	saldotercero;