-- Function to control order expiration - resets inventory and disables expired documents
-- Designed to be executed daily via cron job

CREATE OR REPLACE FUNCTION control_vencimiento_pedidos()
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    documentos_affected INTEGER := 0;
    start_time TIMESTAMP;
    end_time TIMESTAMP;
BEGIN
    -- Log execution start
    start_time := CLOCK_TIMESTAMP();
    
    RAISE NOTICE 'Starting order expiration control at %', start_time;
    
    -- Main operation: Reset expired order inventories and disable documents
    WITH expired_documents AS (
        SELECT DISTINCT
            d.ndocumento
        FROM    
            documentos_standar ds
        INNER JOIN documentos_sucursales dsu
            ON dsu.id_documento = ds.id_documento
        INNER JOIN documentos d
            ON dsu.codigo_tipo = d.codigo_tipo
        INNER JOIN info_documento id 
            ON d.ndocumento = id.ndocumento		
        WHERE
			id.procesado = false -- solo los pedidos que se no se han facturado
            and ds.nombre = 'MOSTRADOR'
            AND d.estado = true
            AND d.fecha::date + INTERVAL '1 day' * id.vencimiento < CURRENT_DATE -- y que se hayan vencido
    ),
    -- Update inventarios
    inventarios_update AS (
        UPDATE inventarios 
        SET 
            entrada = 0,
            salida = 0
        WHERE 
            ndocumento IN (SELECT ndocumento FROM expired_documents)
            AND (entrada != 0 OR salida != 0)
        RETURNING 1
    ),
    -- Count affected inventarios rows
    inventarios_count AS (
        SELECT COUNT(*) as affected FROM inventarios_update
    )
    -- Update documentos and get count
    UPDATE documentos 
    SET 
        estado = false
    WHERE 
        ndocumento IN (SELECT ndocumento FROM expired_documents)
        AND estado = true;
    
    -- Get affected row counts
    GET DIAGNOSTICS documentos_affected = ROW_COUNT;    
    
    -- Log completion
    end_time := CLOCK_TIMESTAMP();
    
    RAISE NOTICE 'Order expiration control completed at %', end_time;
    RAISE NOTICE 'Execution time: %', (end_time - start_time);
    RAISE NOTICE 'Documents disabled: %', documentos_affected;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in control_vencimiento_pedidos: %', SQLERRM;
END;
$$;

-- Grant execution permissions (adjust role as needed)
-- GRANT EXECUTE ON FUNCTION control_vencimiento_pedidos() TO your_application_role;

-- Example usage:
-- SELECT control_vencimiento_pedidos();

/*
CRON JOB SETUP INSTRUCTIONS:

1. Connect to your server and edit the crontab:
   sudo crontab -e

2. In /usr/local/bin/ put control_vencimiento_pedidos.sh, this file is in this directory as well


3. Add this line to run daily at 2 AM:
   * 2 * * *       /usr/local/bin/control_vencimiento_pedidos.sh >> /var/log/order_expiration_test.log 2>&1

