DROP TABLE IF EXISTS aux_params;
CREATE TEMP TABLE aux_params AS
SELECT
	'?'::BIGINT AS ndocumento,
	'?'::FLOAT8 AS valor;
	
INSERT INTO datos_documento(ndocumento,valor,cxc) 
SELECT
	ndocumento,
	valor,
	valor
FROM
	aux_params;