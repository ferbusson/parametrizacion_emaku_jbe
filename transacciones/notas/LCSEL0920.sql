drop table if exists aux_libro_auxiliar_consulta;
create temp table aux_libro_auxiliar_consulta as
SELECT
	l.orden,
	l.id_centrocosto,
	l.id_scentrocosto,
	c.char_cta,
	c.nombre,
	l.id_cta,
	l.id_tercero,
	l.ndocumento,
	l.ndocumento_enlace,
	l.id_prod_serv,
	l.debe,
	l.haber,
	d.codigo_tipo,
	COALESCE(rd.valor_base,0) AS base,
	l.detalle,
	pc.terceros,
	pc.centro ,
	pc.scentro,
	pc.vinculada,
	pc.edocumento,
	pc.retencion,
	l.id_vinculo_movimiento,
	l.ex_documento,
	CASE 
        WHEN l.ndocumento_enlace IS NOT NULL THEN 
            SUM(CASE WHEN l.ndocumento_enlace IS NOT NULL THEN 1 ELSE 0 END) 
            OVER (
                ORDER BY l.haber -- le damos numeracion a cada doc basados en su valor
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            )
        ELSE NULL 
    END AS contador
from
	libro_auxiliar l
inner join
	documentos d
on
	l.ndocumento = d.ndocumento
inner join
	cuentas c
on
	l.id_cta = c.id_cta
inner join
	perfil_cta pc
on
	c.id_cta = pc.id_cta	
LEFT OUTER JOIN
 	retenciones_documento rd
ON
 	l.ndocumento = rd.ndocumento AND
 	l.id_cta = rd.id_cta AND
 	case when d.codigo_tipo not in ('IC','G1','AT','EA','DC','ED','GI','DO','DQ','RC','M1','CJ') then l.id_tercero = rd.id_tercero else true end and -- las devs en compra no guardan el id_tercero Feb 17 2025
 	abs(l.haber-l.debe) = rd.valor_retencion
WHERE
	d.codigo_tipo='?' AND
	d.numero=LPAD('?',10,'0');

--

SELECT
	/* 0 */ foo.char_cta,
	/* 1 */ foo.detalle,
	/* 2 */ foo.debe,
	/* 3 */ foo.haber,
	/* 4 */ foo.base,
	/* 5 */ foo.id_char,
	/* 6 */ numero,
	/* 7 */ foo.centrocosto,
	/* 8 */ foo.ex_documento,
	/* 9 */ foo.scentrocosto,
	/* 10 */ v.codigo AS vinculo,
	/* 11 */ foo.terceros,
	/* 12 */ foo.centro,
	/* 13 */ foo.scentro,
	/* 14 */ foo.vinculada,
	/* 15 */ foo.edocumento,
	/* 16 */ foo.retencion,
	/* 17 */ id_tercero,
	/* 18 */ foo.id_prod_serv AS id_producto,
	/* 19 */ foo.id_cta,
	/* 20 */ NEXTVAL('orden_seq'),
	/* 21 */ nombret,
	/* 22 */ foo.nfactura,
	/* 23 */ nombretimp,
	/* 24 */ detalleimp,
	/* 25 */ numdocimp,
	/* 26 */ foo.nombre,
	/* 27 */ 0 as id_activo
FROM	
	(SELECT
		foo.char_cta,
		foo.detalle,
		foo.debe,
		foo.haber,
		foo.base,
		foo.id_char,
		numero,
		foo.codigo AS centrocosto,
		s.codigo AS scentrocosto,	
		foo.nombre,
		foo.terceros,
		foo.id_prod_serv,
		foo.centro,
		foo.scentro,
		COALESCE(foo.id_tercero,0) AS id_tercero,
		foo.id_cta,
		foo.vinculada,
		foo.edocumento,
		foo.retencion,
		foo.id_vinculo_movimiento,
		foo.orden,
		nombret,
	 	foo.nfactura,
	 	nombretimp,
	 	detalleimp,
	 	numdocimp,
		foo.ex_documento
	FROM
		(SELECT
			foo.char_cta,
			foo.debe,
			foo.haber,
			foo.base,
			foo.id_char,
			coalesce(doc.numero,doc2.numero) as numero,
			--doc.numero,
			foo.codigo,
			foo.id_scentrocosto,
			foo.id_centrocosto,
			foo.id_prod_serv,
			foo.nombre,
			foo.terceros,
			foo.detalle,
			foo.centro,
			foo.scentro,
			foo.id_tercero,
			foo.id_cta,
			foo.vinculada,
			foo.edocumento,
			foo.retencion,
			foo.id_vinculo_movimiento,
			foo.orden,
			nombret,
		 	coalesce(doc.nfactura,doc2.nfactura) as nfactura,
			--doc.nfactura,
		 	SUBSTRING(foo.id_char||'-'||nombret,1,30) AS nombretimp,
		 	SUBSTRING(foo.detalle,1,41) AS detalleimp,
		 	coalesce(doc.numero_exdocumento,doc2.numero_exdocumento) as numdocimp,
		 	foo.ex_documento
		FROM
			(select
				foo.codigo_tipo,
				foo.orden,
				foo.char_cta,
				foo.nombre,
				g.id_char,
				foo.id_cta,
				foo.id_tercero,
				foo.ndocumento,
				foo.ndocumento_enlace,
				foo.id_prod_serv,
				foo.debe,
				foo.haber,
				foo.base,
				foo.terceros,
				foo.id_centrocosto,
				foo.detalle,
				foo.codigo,
				foo.id_scentrocosto,
				foo.scentro,
				foo.centro,
				foo.vinculada,
				foo.edocumento,
				foo.retencion,
				foo.id_vinculo_movimiento,
				foo.contador,
				TRIM(COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.razon_social,'')) AS nombret,
				foo.ex_documento
			FROM
				(select
					foo.codigo_tipo,
					foo.orden,
					foo.char_cta,
					foo.nombre,
					foo.id_cta,
					foo.id_tercero,
					foo.ndocumento,
					foo.ndocumento_enlace,
					foo.id_prod_serv,
					foo.debe,
					foo.haber,
					foo.base,
					foo.terceros,
					foo.id_centrocosto,
					foo.detalle,					
					--CASE WHEN foo.centro and foo.codigo_tipo IN ('EA','DC') THEN 'CCB1' ELSE c.codigo END AS codigo,
					c.codigo,
					foo.id_scentrocosto,
					foo.scentro,
					foo.centro,
					foo.vinculada,
					foo.edocumento,
					foo.retencion,
					foo.id_vinculo_movimiento,
					foo.ex_documento,
					foo.contador
				FROM
					aux_libro_auxiliar_consulta AS foo
				LEFT OUTER JOIN
					centrocosto c
				ON
					foo.id_centrocosto=c.id_centrocosto) AS foo
			LEFT OUTER JOIN
				general g
			ON
				foo.id_tercero=g.id) AS foo
		LEFT OUTER JOIN
			(SELECT
				d.codigo_tipo||'-'||d.numero::BIGINT AS numero,
				substring(case when id.ex_documento is null or id.ex_documento = '' then d.codigo_tipo||'-'||d.numero::bigint else d.codigo_tipo||'-'||d.numero::bigint||'/'||COALESCE(id.ex_documento,'') end,1,22) as numero_exdocumento,
				c.id_cta,
				c.idtercero,
				c.nfactura,
				c.ncomprobante,
				row_number() over (order by SUM(c.abono_comprobante)) as contador, -- le damos numeracion a cada doc basados en su valor
				SUM(c.abono_comprobante) AS abono_comprobante,
				SUM(c.cargo_comprobante) AS cargo_comprobante
			 FROM
				documentos d,
				info_documento id,
				(select distinct a.id_tercero from aux_libro_auxiliar_consulta a) as a,
				cartera c
			 where
			 	c.idtercero = a.id_tercero and
			 	d.estado AND
				c.nfactura=d.ndocumento and
				d.ndocumento = id.ndocumento and
				c.ncomprobante = (select ndocumento from aux_libro_auxiliar_consulta limit 1)
			GROUP BY
				d.codigo_tipo||'-'||d.numero::BIGINT,
				id.ex_documento,
				c.id_cta,
				c.idtercero,
				c.nfactura,
				c.ncomprobante) AS doc
		ON
			doc.id_cta=foo.id_cta AND
			doc.contador=foo.contador AND
			foo.edocumento and
			foo.ndocumento_enlace is not null and
			doc.ncomprobante=foo.ndocumento AND
			doc.idtercero=foo.id_tercero
		LEFT OUTER JOIN
			(select --este bloque se encarga de listar los documentos relacionados con el que se consulta en la nota, se agrega para completar la info cuando se llama a una dev en compra DC-2885 Feb 17 2025
				d.codigo_tipo||'-'||d.numero::BIGINT AS numero,
				substring(case when id.ex_documento is null or id.ex_documento = '' then d.codigo_tipo||'-'||d.numero::bigint else d.codigo_tipo||'-'||d.numero::bigint||'/'||COALESCE(id.ex_documento,'') end,1,22) as numero_exdocumento,
				c.id_cta,
				c.idtercero,
				c.nfactura,
				c.ncomprobante,
				SUM(c.abono_comprobante) AS abono_comprobante,
				SUM(c.cargo_comprobante) AS cargo_comprobante
			 FROM
				documentos d,
				info_documento id,
				(select distinct a.id_tercero from aux_libro_auxiliar_consulta a) as a,
				cartera c
			 where
			 	c.idtercero = a.id_tercero and
			 	d.estado AND
				c.nfactura=d.ndocumento and
				d.ndocumento = id.ndocumento
			GROUP by
				d.codigo_tipo||'-'||d.numero::BIGINT,
				id.ex_documento,
				c.id_cta,
				c.idtercero,
				c.nfactura,
				c.ncomprobante) AS doc2
		ON
			doc2.id_cta=foo.id_cta AND
			doc2.ncomprobante=foo.ndocumento and
			-- 25 Nov 2025: este bloque hace que si quieren editar una DC se muestre la entrada almacen a la que pertenece por medio del registro en cartera que estos dos documentos 
			-- comparten, se hace asi porque la dev en compra no enlaza a la EA en libro_auxiliar por medio de ndocumento_enlace, pero se evita que otros documentos hagan ese mismo 
			-- join porque se duplican los registros por eso el false en el else, si existe ndocumento_enlace no hay problema
			case when foo.ndocumento_enlace is not null then doc2.nfactura=foo.ndocumento_enlace when foo.ndocumento_enlace is null and foo.codigo_tipo = 'DC' then true else false end AND
			doc2.idtercero=foo.id_tercero
			) AS foo
	LEFT OUTER JOIN
		scentrocosto s
	ON
		s.id_scentrocosto = foo.id_scentrocosto
	ORDER BY
		orden) AS foo
LEFT OUTER JOIN
	vinculo_movimientos v
ON
	v.id_vinculo_movimiento = foo.id_vinculo_movimiento
ORDER BY
	foo.orden;
