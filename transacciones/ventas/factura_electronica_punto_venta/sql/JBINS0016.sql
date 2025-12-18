-- JBINS0016
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
    foo.dcredito,
    foo.neto_factura,
    foo.total_factura,
    foo.movimiento,
    foo.id_cta
from 
    (SELECT 
        '?' as nfactura,
        '?' as idtercero,
        COALESCE('?',0) as dcredito,
        '?' as neto_factura,
        '?' as total_factura,
        true as movimiento,
        (SELECT id_cta FROM cuentas WHERE char_cta = '?') as id_cta) as foo
where
    foo.total_factura <> 0
    and foo.id_cta is not null;