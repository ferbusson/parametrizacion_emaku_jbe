SELECT
	r_nitcc AS nitcc,
	r_nombre AS nombre,
	r_fecha::DATE AS fecha,
	r_documento AS documento,
	r_comprobante AS comprobante,
	r_total_factura AS total_factura,
	r_abono_comprobante AS abono_comprobante,
	r_cargo_comprobante AS cargo_comprobante,
	r_saldo AS saldo
FROM
	saldos_cartera_documentos_cxc('?','?','?');