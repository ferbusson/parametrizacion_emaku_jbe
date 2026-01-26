DROP TABLE IF EXISTS aux_codigo_corregir;

CREATE TEMP TABLE aux_codigo_corregir AS
SELECT 
    '7704488222864'::varchar AS codigo,
    '5892201'::varchar AS cod_sap;

SELECT * FROM prod_serv 
WHERE codigo = (SELECT codigo FROM aux_codigo_corregir);

BEGIN;
    UPDATE prod_serv 
    SET codigo_b = (SELECT cod_sap FROM aux_codigo_corregir)
    WHERE codigo = (SELECT codigo FROM aux_codigo_corregir);
    
    SELECT * FROM prod_serv 
    WHERE codigo = (SELECT codigo FROM aux_codigo_corregir);
COMMIT;