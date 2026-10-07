drop table if exists cupotercero;
CREATE TEMP TABLE cupotercero AS
SELECT 
	i.id,
	COALESCE(i.cupomaximo,0) AS cupomaximo,
	coalesce(i.diascredito,0) as diascredito,
	i.estado,
	cu.id_cta,
	foo.char_cta,
	case when p.id is not null then 1 else 0 end as empleado -- 1 si es empleado 0 si no lo es
from
	(select
		trim('?'::text) as id, --(select id from general where id_char = '901506443')
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

DROP TABLE IF EXISTS saldotercero;	
CREATE TEMP TABLE saldotercero AS
select
		foo.idtercero,
		foo.fecha_vencimiento,
		foo.empleado,
		foo.char_cta,
        COALESCE(SUM(saldo),0) AS saldo
FROM
        (select
        	c.idtercero,
        	c.fecha_vencimiento,
            c.tfactura+COALESCE(co.cargos,0)-COALESCE(co.vcomprobante,0) AS saldo,
            c.empleado,
            c.char_cta
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
	               	cupotercero.char_cta in ('13050501','13050503') and
                    --cupotercero.char_cta = ac.char_cta and
					ac.char_cta in ('13050501','13050503') AND
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
                	c.id_cta = (select id_cta from cupotercero limit 1) and
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
	foo.idtercero,
	foo.char_cta,
	foo.empleado;
                
--

/*
DROP TABLE IF EXISTS error_msg;
CREATE TEMP TABLE error_msg AS
SELECT 
	1
FROM
	(SELECT
		error_text('El cliente tiene ('||foo.facturasvencidas||') facturas vencidas. debe cancelar facturas crédito vencidas antes de poder acceder a un nuevo crédito JBE o Covifactura')
	FROM
		(select
			coalesce(sum(case when fecha_vencimiento::date < current_date then 1 else 0 end),0) as facturasvencidas 
		from
			saldotercero
		where
			char_cta in ('13050501','13050503')
		having 
			coalesce(sum(case when fecha_vencimiento::date < current_date then 1 else 0 end),0)>0
			) AS foo) AS foo;
*/

-- si la suma es mayor a cero significa que al menos una de las facturas esta vencida
select
		COALESCE(SUM(CASE WHEN (CURRENT_DATE - fecha_vencimiento::date) > 10 then 1 else 0 end),0) 		 
from
	saldotercero;
