--JBSEL0041
select
    1::smallint as id_tipo,
    'Contado'::varchar(20) as descripcion
union all
select
    2::smallint as id_tipo,
    'Crédito'::varchar(20) as descripcion
order BY
    id_tipo;