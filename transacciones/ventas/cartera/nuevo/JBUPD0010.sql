DROP TABLE IF EXISTS aux_parametros_cartera;
CREATE TEMP TABLE aux_parametros_cartera AS
SELECT
	'?'::BIGINT AS ndocumento,
    '?'::INTEGER AS id_centrocosto,
    '?'::INTEGER AS idtercero;


UPDATE
    libro_auxiliar as l
SET
    debe = la_n.haber
from
    aux_parametros_cartera a,
    libro_auxiliar_niifs la_n
WHERE
    a.idtercero = 830 -- solo si se trata de sitecredito
    and a.ndocumento = la_n.ndocumento
    and a.ndocumento = l.ndocumento
	and l.id_cta = la_n.id_cta
	and coalesce(l.id_tercero,-1) = coalesce(la_n.id_tercero,-1);

UPDATE
    libro_auxiliar as l
SET
    haber = la_n.debe
from
    aux_parametros_cartera a,
    libro_auxiliar_niifs la_n
WHERE
    a.idtercero = 830 -- solo si se trata de sitecredito
    and a.ndocumento = la_n.ndocumento
    and a.ndocumento = l.ndocumento
    and l.id_cta = la_n.id_cta
	and coalesce(l.id_tercero,-1) = coalesce(la_n.id_tercero,-1);

