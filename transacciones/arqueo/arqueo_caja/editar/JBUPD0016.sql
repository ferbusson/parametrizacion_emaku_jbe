DROP TABLE IF EXISTS args_arqueo;
CREATE TEMP TABLE args_arqueo AS
SELECT DISTINCT
	i.ndocumento AS narqueo,
	i.id_usuario
from
	info_documento i
WHERE
	i.ndocumento = '?';

/*
DELETE FROM
	libro_auxiliar
USING
	args_arqueo a
WHERE
	libro_auxiliar.ndocumento = a.narqueo;
*/

UPDATE 
	efectivo 
SET
	dolares='?',
	"100000"='?',
	"50000"='?',
	"20000"='?',
	"10000"='?',
	"5000"='?',
	"2000"='?',
	"1000"='?',
	monedas='?',
	tcredito='?',
        tdebito='?',
        tfcredito='?',
        "100"='?',
        "50"='?',
        "20"='?',
        "10"='?',
        "5"='?',
        "1"='?',
        monedasd='?',
        tregalo='?',
        tsodexo = '?',
        tbigpass = '?',
        retiros_parciales = '?'
FROM
	documentos d,
	args_arqueo a
WHERE
	efectivo.narqueo = a.narqueo;

-- INICIA INSERCION CONTABILIZACIÓN ARQUEO


-- SUMA ENTREGAS DE BASE SENCILLA
/*
DROP TABLE IF EXISTS suma_base_sencilla;
CREATE TEMP TABLE suma_base_sencilla AS
SELECT
	COALESCE(SUM(dd.valor),0) AS valor
FROM
	documentos d,
	args_arqueo a,
	datos_arqueo da,
	datos_documento dd,
	documentos_standar dst,
	documentos_sucursales ds
WHERE
	d.estado AND 
	a.narqueo = da.narqueo AND
	da.ndocumento = d.ndocumento AND
	d.codigo_tipo = ds.codigo_tipo AND
	d.ndocumento = dd.ndocumento AND
	ds.id_documento = dst.id_documento AND
	dst.nombre = 'ENTREGA BASE SENCILLA';

-- CONTRAPARTIDA ENTREGA BASE SENCILLA
INSERT INTO
	libro_auxiliar(
		id_cta,
		id_centrocosto,
		id_tercero,
		fecha,
		detalle,
		ndocumento,
		debe,
		haber)		
SELECT 
	cu.id_cta,
	a.id_centrocosto,
	a.id_usuario,
	a.fecha, --CURRENT_TIMESTAMP AS fecha,
	'CONTRAPARTIDA ENTREGA BASE SENCILLA' AS detalle,
	a.narqueo AS ndocumento,
	COALESCE(s.valor,0.0) AS debe,
	0.0 AS haber
FROM 	
	args_arqueo a,
	cuentas cu,
	suma_base_sencilla s
WHERE 
	cu.char_cta = '11051502' AND
	s.valor != 0
UNION
SELECT 
	cu.id_cta,
	a.id_centrocosto,
	a.id_usuario,
	a.fecha, --CURRENT_TIMESTAMP AS fecha,
	'CONTRAPARTIDA ENTREGA BASE SENCILLA' AS detalle,
	a.narqueo AS ndocumento,
	0.0 AS debe,
	COALESCE(s.valor,0.0) AS haber
FROM 	
	args_arqueo a,
	cuentas cu,
	suma_base_sencilla s
WHERE 
	cu.char_cta = '11051501' AND
	s.valor != 0;
*/
