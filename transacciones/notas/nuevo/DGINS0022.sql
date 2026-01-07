INSERT INTO 
			cartera(
				nfactura,
				idtercero,
				dcredito,
				neto_factura,
				total_factura,
				movimiento,
				id_cta) 
		SELECT
			foo.nfactura,
			foo.idtercero,
			COALESCE(foo.dcredito::INTEGER,0) AS dcredito,
			foo.neto_factura,
			foo.total_factura,
			CASE WHEN SUBSTRING(char_cta,1,1) = '1' THEN TRUE ELSE FALSE END AS movimiento,
			foo.id_cta
		FROM
			(SELECT
				'?'::INTEGER AS nfactura,
				'?'::FLOAT8 AS dcredito,
				'?'::INTEGER AS idtercero,
				'?'::FLOAT8 AS neto_factura,
				'?'::FLOAT8 AS total_factura,
				'?'::INTEGER AS id_cta) AS foo,
			cuentas c
		WHERE
			foo.id_cta = c.id_cta;