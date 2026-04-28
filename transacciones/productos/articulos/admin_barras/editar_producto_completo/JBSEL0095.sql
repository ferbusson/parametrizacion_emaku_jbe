SELECT 
    cp.nombre AS catalogo,        
    ct.pventa_lista_1,
    ct.pventa_lista_2,
    ct.pventa_lista_3,
    ct.id_catalogo
FROM crosstab(
    'SELECT pv.id_catalogo, pv.id_lista, pv.pventa
     FROM pventa pv
     INNER JOIN prod_serv ps ON ps.id_prod_serv = pv.id_prod_serv
     WHERE ps.codigo = ''BOT''
     ORDER BY pv.id_catalogo',

    'VALUES (1), (2), (3)'
) AS ct(
    id_catalogo    INT,
    pventa_lista_1 NUMERIC,
    pventa_lista_2 NUMERIC,
    pventa_lista_3 numeric
)
INNER JOIN catalogo_pventa cp ON ct.id_catalogo = cp.id_catalogo
ORDER BY ct.id_catalogo;