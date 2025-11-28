--JBINS0011
/*inserta cruce con anticipo desde factura electronica teniendo en cuenta que:
 * los anticipos se guardan en cartera con nfactura = null porque son anticipos abiertos
 * - si el valor cruzado en la factura es igual al valor del anticipo seleccionado el registro orignal se borra
 * - si el valor cruzado en la factura es menor al valor del anticipo selecccionado el registro original se actualiza
 * para que el saldo quede disponible con nfactura = null
 * - el valor cruzado en la factura no puede ser mayor al valor del anticipo selecccionado, validar en el formulario*/
with aux_parametros_insert as (
 (SELECT
		'?'::BIGINT AS nfactura,
		'?'::BIGINT AS idtercero,
		'?'::BIGINT AS ncomprobante,
		'?'::FLOAT8 AS abono_comprobante,
		'?'::FLOAT8 AS pdcto_comprobante,
		'?'::FLOAT8 AS dcto_comprobante,
		'?'::FLOAT8 AS pdcto2_comprobante,
		'?'::FLOAT8 AS pdcto3_comprobante,
		'?'::INTEGER id_cta)
),
aux_revision_cartera as (
    select
    	c.ncomprobante,
        case when c.abono_comprobante = a.abono_comprobante -- borrar registro anterior
             then true -- borrar registro 
        when c.abono_comprobante > a.abono_comprobante then false --actualizar registro anterior
        end as validacion,
        case when c.abono_comprobante = a.abono_comprobante -- borrar registro anterior
             then 0
        when c.abono_comprobante > a.abono_comprobante then c.abono_comprobante-a.abono_comprobante
        end as nuevo_valor_anticipo_original
    from
        cartera c
      inner join
      	aux_parametros_insert a
    on
        c.ncomprobante = a.ncomprobante
    where
    	c.nfactura is null
),
aux_insertar_nuevo_registro as (
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
        movimiento,
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
    false AS movimiento,
	id_cta
FROM
	 aux_parametros_insert),
aux_borrar_registro_anterior as (
delete from
	cartera as ca
using
	aux_revision_cartera a
where
	a.validacion = true
	and ca.ncomprobante = a.ncomprobante)
-- actualizar el registro anterior si el valor usado en factura es menor al anticipo hecho	
update
	cartera as ca
set
	abono_comprobante = a.nuevo_valor_anticipo_original
from
	 aux_revision_cartera a
where
	ca.ncomprobante = a.ncomprobante
	and a.validacion = false
    and ca.nfactura is null;
