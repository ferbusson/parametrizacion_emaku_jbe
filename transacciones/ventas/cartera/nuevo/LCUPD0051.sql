DROP TABLE IF EXISTS aux_parametros_cartera;
CREATE TEMP TABLE aux_parametros_cartera AS
SELECT
	'?'::BIGINT AS ncomprobante,
	'?'::INTEGER AS idtercero,
	'?'::BIGINT AS nfactura,
	'?'::FLOAT8 AS abono_comprobante,
	'?'::FLOAT8 AS pdcto_comprobante,
	'?'::FLOAT8 AS dcto_comprobante,
	'?'::INTEGER AS id_cta,
	'?'::FLOAT8 AS saldo_anterior;

-- actualiza ndocumento_enlace de acuerdo a las facturas pagadas
UPDATE
	libro_auxiliar AS l
SET
	--id_centrocosto = l2.id_centrocosto,
	ndocumento_enlace = a.nfactura
FROM
	aux_parametros_cartera a,
	libro_auxiliar l2
WHERE
	a.nfactura = l2.ndocumento AND
	a.id_cta = l2.id_cta AND
	a.idtercero = l2.id_tercero AND
	l.ndocumento = a.ncomprobante AND
	l.id_cta = a.id_cta AND
	l.id_tercero = a.idtercero;
	
-- actualiza id_centrocosto de todo el libro_auxiliar
UPDATE
	libro_auxiliar AS l
SET
	id_centrocosto = l2.id_centrocosto
FROM
	aux_parametros_cartera a,
	libro_auxiliar l2
WHERE
	a.nfactura = l2.ndocumento AND
	a.id_cta = l2.id_cta AND
	a.idtercero = l2.id_tercero AND
	l.ndocumento = a.ncomprobante;