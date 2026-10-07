-- LCUPD0040

-- Parameters (same order as original, no change):
--   param 1 – ex_documento
--   param 2 – vencimiento
--   param 3 – rf_documento
--   param 4 – ndocumento
--
-- When 0 rows are affected the app should surface a duplicate-ex_documento error.

DROP TABLE IF EXISTS aux_parametros_query;
CREATE temp TABLE aux_parametros_query as
    SELECT
        '?'::VARCHAR    AS ex_documento,   -- param 1
        '?'::SMALLINT   AS vencimiento,    -- param 2
        '?'::BIGINT     AS rf_documento,   -- param 3
        '?'::BIGINT     AS ndocumento;      -- param 4 this ndocumento will always come from the form dedicated to EA documents

--

DROP TABLE IF EXISTS error_msg;
CREATE TEMP TABLE error_msg AS
SELECT 
	1
FROM
	(SELECT
		error_text('No es posible guardar dos veces la factura: '||trim(foo.ex_documento)||'. Ingresada anteriormente en la: '||foo.documento)
	FROM
		(select
			d.codigo_tipo||'-'||d.numero::bigint as documento,
			trim(id.ex_documento) as ex_documento
		from
			info_documento id		
		join
			
			documentos d
		on
			id.ndocumento = d.ndocumento
		where
			d.estado
			and exists (select 1 from aux_parametros_query a where trim(id.ex_documento) = trim(a.ex_documento))
	) AS foo) AS foo;

--
			
UPDATE 
	info_documento i
SET
    ex_documento = p.ex_documento,
    vencimiento  = p.vencimiento,
    rf_documento = p.rf_documento
from
	aux_parametros_query p
WHERE
    i.ndocumento = p.ndocumento;
