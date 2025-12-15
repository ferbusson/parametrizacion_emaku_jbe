-- JBSEL0042


SELECT  
    'Mostrador' as catalogo,
    0.0 as mostrador,
    0.0 as abanico,
    0.0 as base,
    0.0 as utilidad_mostrador,
    0.0 as utilidad_abanico,
    0.0 as utilidad_base,
    0.0 as costo,
    1 as id_catalogo
union all
SELECT  
    'Subdistribución Pasto' as catalogo,
    0.0 as mostrador,
    0.0 as abanico,
    0.0 as base,
    0.0 as utilidad_mostrador,
    0.0 as utilidad_abanico,
    0.0 as utilidad_base,
    0.0 as costo,
    2 as id_catalogo
union all
SELECT  
    'Subdistribución Poblaciones' as catalogo,
    0.0 as mostrador,
    0.0 as abanico,
    0.0 as base,
    0.0 as utilidad_mostrador,
    0.0 as utilidad_abanico,
    0.0 as utilidad_base,
    0.0 as costo,
    3 as id_catalogo
order by 
	id_catalogo;




