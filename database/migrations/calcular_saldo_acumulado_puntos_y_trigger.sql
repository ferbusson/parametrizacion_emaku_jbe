-- Función para calcular el saldo acumulado de puntos
CREATE OR REPLACE FUNCTION calcular_saldo_acumulado_puntos()
RETURNS TRIGGER AS $$
DECLARE
    saldo_anterior INTEGER;
BEGIN
    -- Obtener el saldo anterior más reciente para este id_tercero
    SELECT saldo INTO saldo_anterior
    FROM puntos_tercero
    WHERE id_tercero = NEW.id_tercero
    ORDER BY fecha DESC, id_puntos_tercero DESC
    LIMIT 1;
    
    -- Si no hay registros anteriores, el saldo anterior es 0
    saldo_anterior := COALESCE(saldo_anterior, 0);
    
    -- Calcular el nuevo saldo: saldo anterior + puntos generados - puntos redimidos
    NEW.saldo := saldo_anterior + COALESCE(NEW.puntos_generados, 0) - COALESCE(NEW.puntos_redimidos, 0);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_calcular_saldo_acumulado_puntos
    BEFORE INSERT ON puntos_tercero
    FOR EACH ROW
    EXECUTE PROCEDURE calcular_saldo_acumulado_puntos();