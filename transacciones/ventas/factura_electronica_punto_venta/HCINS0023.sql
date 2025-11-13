INSERT INTO 
	cartera(
		ncomprobante,
		idtercero,
		nfactura,
		abono_comprobante,
		pdcto_comprobante,
		dcto_comprobante,
		pdcto2_comprobante,
		pdcto3_comprobante,
		id_cta) 
SELECT
	ncomprobante,
	idtercero,
	nfactura,
	abono_comprobante,
	pdcto_comprobante,
	dcto_comprobante,
	pdcto2_comprobante,
	pdcto3_comprobante,
	id_cta
FROM
	(SELECT
		'?'::BIGINT AS ncomprobante,
		'?'::BIGINT AS idtercero,
		'?'::BIGINT AS nfactura,
		'?'::FLOAT8 AS abono_comprobante,
		'?'::FLOAT8 AS pdcto_comprobante,
		'?'::FLOAT8 AS dcto_comprobante,
		'?'::FLOAT8 AS pdcto2_comprobante,
		'?'::FLOAT8 AS pdcto3_comprobante,
		'?'::INTEGER id_cta) AS foo;