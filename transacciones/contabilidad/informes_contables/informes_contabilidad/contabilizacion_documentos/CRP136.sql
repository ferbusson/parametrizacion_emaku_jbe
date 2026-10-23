SELECT
	foo.fecha,
	foo.descripcion,
	foo.numero,
	foo.descripcion,
	foo.centro,
	s.codigo AS scentro,
	foo.char_cta,
	--foo.nombre,--AQUI
	substring(foo.nombre_tercero,1,60) as nombre,
	foo.id_char,	
	foo.codigo,
	foo.debe,
	foo.haber
FROM
	(SELECT
		foo.fecha,
		foo.ndocumento,
		foo.descripcion,
		foo.numero,
		c.codigo AS centro,
		foo.id_scentrocosto,
		foo.char_cta,
		foo.nombre,
		foo.id_char,
		foo.nombre_tercero,
		foo.codigo,
		foo.debe,
		foo.haber
	FROM	
		(SELECT
			ld.fecha,
			ld.ndocumento,
			ld.numero,
			ld.descripcion,
			ld.id_centrocosto,
			ld.id_scentrocosto,
			ld.char_cta,
			ld.nombre,
			ld.id_char,
			ld.nombre_tercero,
			p.codigo,
			ld.debe,
			ld.haber
		FROM	
			(SELECT
				th.fecha,
				th.ndocumento,
				th.numero,
				th.descripcion,
				th.id_centrocosto,
				th.id_scentrocosto,
				th.char_cta,
				th.nombre,
				th.id_char,
				th.nombre_tercero,
				th.id_prod_serv,
				th.debe,
				th.haber
			FROM
				(SELECT
					ax.fecha,
					ax.ndocumento,
					ax.numero,
					ax.descripcion,
					ax.id_centrocosto,
					ax.id_scentrocosto,
					ax.char_cta,
					ax.nombre,
					g.id_char,
					trim(coalesce(g.nombre1,'')||' '||coalesce(g.nombre2,'')||' '||coalesce(g.apellido1,'')||' '||coalesce(g.apellido2,'')||' '||coalesce(g.razon_social,'')) as nombre_tercero,
					ax.id_prod_serv,
					ax.debe,
					ax.haber
				FROM
					(SELECT
						l.fecha::date AS fecha,
						l.ndocumento,
						--concat_ws available since 9.1: skips NULL arguments and doesn’t emit separators for them
						concat_ws(' | ', --separator
							d.codigo_tipo||'-'||d.numero::bigint, --string1
							nullif(id.ex_documento,''), --string2
							nullif(l.ex_documento,'') --string3
							) as numero,
						t.descripcion,
						l.id_centrocosto,
						l.id_scentrocosto,
						c.char_cta,
						c.nombre,
						l.id_tercero,
						l.id_prod_serv,
						sum(l.debe) AS debe,
						sum(l.haber) AS haber
					FROM
						cuentas c,
						libro_auxiliar l,						
						tipo_documento t,
						documentos d
					left join
						info_documento id
					on
						d.ndocumento = id.ndocumento
					WHERE
						d.ndocumento=l.ndocumento AND
						d.codigo_tipo=t.codigo_tipo AND
						l.id_cta=c.id_cta AND
						d.codigo_tipo='?' AND
						d.numero= LPAD('?',10,'0')
					GROUP BY
						l.fecha::date,
						l.ndocumento,
						d.codigo_tipo||'-'||d.numero::bigint,	
						id.ex_documento,
						l.ex_documento,
						t.descripcion,
						l.id_centrocosto,
						l.id_scentrocosto,
						c.char_cta,
						c.nombre,
						l.id_tercero,
						l.id_prod_serv) AS ax
					LEFT OUTER JOIN
						general g
					ON
						ax.id_tercero=g.id) AS th) AS ld
					LEFT OUTER JOIN
						prod_serv p
					ON
						p.id_prod_serv=ld.id_prod_serv) AS foo
		LEFT OUTER JOIN
			centrocosto c
		ON
			foo.id_centrocosto = c.id_centrocosto) AS foo
LEFT OUTER JOIN
	scentrocosto s
ON
	foo.id_scentrocosto=s.id_scentrocosto
ORDER BY
	ndocumento,
	char_cta,
	id_char,
	codigo;