-- Función para recalcular saldos desde un punto específico
CREATE OR REPLACE FUNCTION recalcular_saldos_puntos_tercero(
    p_id_tercero INTEGER,
    p_desde_fecha TIMESTAMP DEFAULT NULL
) RETURNS VOID AS $$
DECLARE
    cur_saldo INTEGER := 0;
    r RECORD;
BEGIN
    -- Si no se especifica fecha, recalcular desde el inicio
    IF p_desde_fecha IS NULL THEN
        SELECT saldo INTO cur_saldo
        FROM puntos_tercero 
        WHERE id_tercero = p_id_tercero 
        ORDER BY fecha, id_puntos_tercero 
        LIMIT 1;
        
        cur_saldo := COALESCE(cur_saldo, 0);
    ELSE
        -- Obtener el saldo justo antes de la fecha especificada
        SELECT saldo INTO cur_saldo
        FROM puntos_tercero 
        WHERE id_tercero = p_id_tercero 
          AND fecha < p_desde_fecha
        ORDER BY fecha DESC, id_puntos_tercero DESC
        LIMIT 1;
        
        cur_saldo := COALESCE(cur_saldo, 0);
    END IF;
    
    -- Recalcular saldos desde la fecha especificada
    FOR r IN (
        SELECT id_puntos_tercero, puntos_generados, puntos_redimidos
        FROM puntos_tercero
        WHERE id_tercero = p_id_tercero
          AND (p_desde_fecha IS NULL OR fecha >= p_desde_fecha)
        ORDER BY fecha, id_puntos_tercero
    ) LOOP
        cur_saldo := cur_saldo + COALESCE(r.puntos_generados, 0) - COALESCE(r.puntos_redimidos, 0);
        
        UPDATE puntos_tercero 
        SET saldo = cur_saldo
        WHERE id_puntos_tercero = r.id_puntos_tercero;
    END LOOP;
END;
$$ LANGUAGE plpgsql;