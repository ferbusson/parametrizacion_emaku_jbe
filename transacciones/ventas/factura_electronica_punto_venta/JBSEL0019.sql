SELECT vencimiento
FROM info_documento i,
    documentos d
WHERE i.ndocumento = d.ndocumento
    and case 
                        when d.fecha::date + interval '1 day'*i.vencimiento < CURRENT_DATE then false
                        when d.estado = false then false
                        when i.procesado = true then false
                        else true end
    AND d.codigo_tipo = '?'
    AND numero = LPAD('?', 10, '0')