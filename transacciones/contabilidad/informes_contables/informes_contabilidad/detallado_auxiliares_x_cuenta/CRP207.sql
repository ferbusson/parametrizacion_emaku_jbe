DROP TABLE IF EXISTS args_aux;
CREATE TEMP TABLE args_aux AS
SELECT
	'?'::CHARACTER(10) AS cuenta_inicial,
	'?'::CHARACTER(10) AS cuenta_final,
	'?'::DATE AS fecha_inicial,
	'?'::DATE AS fecha_final,
	COALESCE((SELECT codigo FROM centrocosto WHERE id_centrocosto::VARCHAR = '?'),'') AS codigo_centrocosto;

DROP TABLE IF EXISTS return_aux;
CREATE TEMP TABLE return_aux AS
SELECT
	movimiento_auxiliares_con_cc(cuenta_inicial,cuenta_final,fecha_inicial,fecha_final, codigo_centrocosto)
FROM 
	args_aux;

UPDATE
	aux_mov_nt
SET
	debe=0,
	haber=0
WHERE
	detalle='Saldo inicial';

DROP SEQUENCE serial;
DROP TABLE IF EXISTS resulset_proc_00;
CREATE SEQUENCE serial START 1;
CREATE TEMP TABLE resulset_proc_00 AS
SELECT
	aa.fecha_inicial,
	aa.fecha_final,
	m.fecha AS fechaok,
	m.fecha::TIMESTAMP AS fecha,
	c.id_cta,
	c.char_cta,
	m.centrocosto,
	c.nombre,
	m.ndocumento,
	m.id_tercero,
	m.id_prod_serv,
	m.id_vinculo_movimiento,
	m.detalle,
	m.debe,
	m.haber,
	m.saldo,
	m.ex_documento,
	m.orden as serie,
	--NEXTVAL('serial') AS serie
	--row_number() over(order by case when detalle = 'Saldo Final' then 1 else 0 end,m.fecha) AS serie,
	row_number() over(partition by m.ndocumento, m.id_cta, m.debe order by m.ndocumento, m.id_cta, m.debe) as orden
FROM
	aux_mov_nt m,
	cuentas c,
	args_aux aa
WHERE
	c.id_cta=m.id_cta;
/*
UPDATE
	resulset_proc
SET
	serie = 0
WHERE
	serie = (SELECT MAX(serie) FROM resulset_proc);
*/

drop table if exists aux_tarjetas_con_orden;
create temp table aux_tarjetas_con_orden as
select
	*,
	row_number() over(partition by ndocumento, id_cta, valor order by ndocumento, id_cta, valor) as orden
from
	tarjetas t;
	

DROP TABLE IF EXISTS resulset_proc;
CREATE TEMP TABLE resulset_proc AS
select
	r.fecha_inicial,
	r.fecha_final,
	r.fechaok,
	r.fecha,
	r.id_cta,
	r.char_cta,
	r.centrocosto,
	r.nombre,
	r.ndocumento,
	r.id_tercero,
	r.id_prod_serv,
	r.id_vinculo_movimiento,
	r.detalle,
	r.debe,
	r.haber,
	r.saldo,
	r.ex_documento,
	r.serie,
	r.orden,
	t.orden as orden_tarjetas,
	t.four_numbers
from
	resulset_proc_00 r
left outer join
	aux_tarjetas_con_orden t
on
	r.ndocumento is not null and
	r.id_cta is not null and
	r.debe = t.valor and
	r.ndocumento = t.ndocumento and
	r.id_cta = t.id_cta and	
	r.nombre ilike '%bono%rega%' and
	r.orden = t.orden
group by
	r.fecha_inicial,
	r.fecha_final,
	r.fechaok,
	r.fecha,
	r.id_cta,
	r.char_cta,
	r.centrocosto,
	r.nombre,
	r.ndocumento,
	r.id_tercero,
	r.id_prod_serv,
	r.id_vinculo_movimiento,
	r.detalle,
	r.debe,
	r.haber,
	r.saldo,
	r.ex_documento,
	r.serie,
	r.orden,
	t.orden,
	t.four_numbers
order by
	r.orden;


SELECT
	fechaok,
	fecha,
	char_cta,	
	nombre,	
	centrocosto,
	--detalle,
	nombre_tercero as detalle, -- Oct 23 2026, se reemplaza detalle de la cuenta y se pone el nombre del tercero solicitud JBE
	numero,
	estado,
	id_char,
	--''::varchar as id_char,
	nombre_tercero,
	foo.codigo,
	v.codigo AS codigov,
	v.descripcion AS descripcionv,
	debe,
	haber,
	saldo
FROM
	(SELECT
		fechaok::DATE AS fechaok,
		fecha::DATE AS fecha,
		char_cta,
	 	centrocosto,
		nombre,
		SUBSTRING(detalle,1,20) AS detalle,
		--numero||'/'||case when TRIM(COALESCE(ex_documento,'')) = '' then coalesce(four_numbers,'') else TRIM(COALESCE(ex_documento,COALESCE(four_numbers,''))) end as numero,
		--concat_ws available since 9.1: skips NULL arguments and doesn’t emit separators for them
		concat_ws('/', --separator
			numero, --string1
			nullif(trim(ex_documento),''), --string2
			nullif(trim(four_numbers),''), --string3
			nullif(trim(doc_ext),'') --string4
			) as numero,
		estado,
		id_char,
	 	nombre_tercero,
		codigo,
		id_vinculo_movimiento,
		debe,
		haber,
		saldo,
		serie
	FROM
		(SELECT
			fechaok,
			f.fecha,
			char_cta,
		 	centrocosto,
			nombre,
		 	detalle,
			COALESCE(numero,'') AS numero,
			ndocumento,
			CASE WHEN COALESCE(estado,true) THEN 'H' ELSE 'A' END AS estado,
			COALESCE(id_char,'') AS id_char,
		 	nombre_tercero,
			COALESCE(codigo,'') AS codigo,
			id_vinculo_movimiento,
			debe,
			haber,
			saldo,
			serie,
			four_numbers,
			ex_documento as doc_ext
		FROM
			(SELECT
				fecha_inicial,
				fecha_final,
				fechaok,
				f.fecha,
				char_cta,
			 	centrocosto,
				nombre,
				codigo_tipo,
				numero,
				ndocumento,
				f.estado,
				id_char,
			 	nombre_tercero,
				codigo,
				id_vinculo_movimiento,
				detalle,
				debe,
				haber,
				saldo,
				serie,
				four_numbers,
				ex_documento
			FROM
				(SELECT
					fecha_inicial,
					fecha_final,
					fechaok,
					f.fecha,
					char_cta,
				 	centrocosto,
					nombre,
					codigo_tipo,
					numero,
					ndocumento,
					estado,
					id_char,
				 	COALESCE(TRIM(COALESCE(g.apellido1,'')||' '||COALESCE(g.apellido2,'')||' '||COALESCE(g.nombre1,'')||' '||COALESCE(g.nombre2,'')||' '||COALESCE(razon_social,'')),'') AS nombre_tercero,
					id_prod_serv,
					id_vinculo_movimiento,
					detalle,
					debe,
					haber,
					saldo,
					serie,
					four_numbers,
					ex_documento
				FROM
					(SELECT
						fecha_inicial,
						fecha_final,
						fechaok,
						f.fecha,
						char_cta,
					 	centrocosto,
						nombre,
						codigo_tipo,
						codigo_tipo||'-'||(numero::bigint) AS numero,
						f.ndocumento,
						estado,
						id_tercero,
						id_prod_serv,
						id_vinculo_movimiento,
						detalle,
						debe,
						haber,
						saldo,
						ex_documento,
						serie,
						four_numbers
					FROM
						resulset_proc f
					LEFT OUTER JOIN
						documentos d
					ON
						f.ndocumento=d.ndocumento) AS f
				LEFT OUTER JOIN
					general g
				ON
					f.id_tercero=g.id) AS f
			LEFT OUTER JOIN
				prod_serv p
			ON
				f.id_prod_serv=p.id_prod_serv) AS f
		LEFT OUTER JOIN
			tipo_documento t
		ON
			f.codigo_tipo=t.codigo_tipo) AS f
	LEFT OUTER JOIN
		info_documento i
	ON
		f.ndocumento=i.ndocumento) AS foo
LEFT OUTER JOIN
	vinculo_movimientos v
ON
	v.id_vinculo_movimiento = foo.id_vinculo_movimiento
ORDER BY
    char_cta,
	serie;