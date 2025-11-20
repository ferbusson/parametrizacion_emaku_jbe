-- Procedimiento para eliminar y recalcular
CREATE OR REPLACE PROCEDURE eliminar_puntos_tercero(
    p_ndocumento BIGINT
) AS $$
DECLARE
    v_id_tercero INTEGER;
    v_fecha TIMESTAMP;
BEGIN
    -- Obtener el id_tercero y fecha del registro
    SELECT id_tercero, fecha INTO v_id_tercero, v_fecha
    FROM puntos_tercero 
    WHERE ndocumento = p_ndocumento LIMIT 1;
    
    -- Eliminar el registro
    DELETE FROM puntos_tercero WHERE ndocumento = p_ndocumento;
    
    -- Recalcular saldos desde este punto
    PERFORM recalcular_saldos_tercero(v_id_tercero, v_fecha::TIMESTAMP);
END;
$$ LANGUAGE plpgsql;