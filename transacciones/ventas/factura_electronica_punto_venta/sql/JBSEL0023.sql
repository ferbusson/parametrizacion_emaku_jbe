--JBSEL0023
with aux_documento_buscar as (
SELECT
    d.ndocumento
from
    documentos d
WHERE
    d.codigo_tipo = '?'
    AND d.numero = lpad('?', 10, '0')
    and d.estado
), 
aux_terceros_documento as (
SELECT
    t.id,
    i.id_tercero_referente
from
    aux_documento_buscar a
inner join    
    tercero_def t
on
    a.ndocumento = t.ndocumento
inner join
    info_documento i
on
	a.ndocumento = i.ndocumento
)
select
	CASE -- este case hace que retorne null aunque la subconsulta retorne vacio, con esto evito errores al guardar puntos
		WHEN COUNT(pt.id) > 0 THEN 
			(SELECT pt.id FROM aux_terceros_documento a
			inner join perfil_tercero pt
			on (a.id = pt.id or a.id_tercero_referente = pt.id)
			and pt.es_pintor = true 
			and pt.id_catalogo = 1 
			LIMIT 1)
		ELSE NULL 
	END as id
from
	aux_terceros_documento a
inner join
    perfil_tercero pt
on
    (a.id = pt.id or
    a.id_tercero_referente = pt.id)
    and pt.es_pintor = true -- pintor puede generar puntos
    and pt.id_catalogo = 1; --solo catalogo mostrador puede generar puntos
    