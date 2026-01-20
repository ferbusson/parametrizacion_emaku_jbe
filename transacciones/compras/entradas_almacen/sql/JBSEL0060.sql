DROP TABLE IF EXISTS arg_barra_obs;
CREATE TEMP TABLE arg_barra_obs AS
SELECT
    '?'::integer as id_bodega,
    '?'::integer as id_tercero,
	'?'::VARCHAR AS clave;

DROP TABLE IF EXISTS valid_longitud;
CREATE TEMP TABLE valid_longitud AS
SELECT
	1
FROM
	(SELECT
		error_text('La palabra clave debe ser mayor a 2 caracteres')
	FROM
		arg_barra_obs
	WHERE
		length(clave)<=2 AND
		clave != '%') AS f;

DROP TABLE IF EXISTS aux_productos_busqueda;
CREATE TEMP TABLE aux_productos_busqueda AS
SELECT
    a.id_bodega,
	p.codigo,
	p.codigo||' - '||' '||i.ref_proveedor||' '||i.nombre||' - '||ma.descripcion AS descripcion,
	trim(i.nombre) as nombre,
	p.id_prod_serv 
FROM 
	item i,
	marcas ma,
	proveedor_marca pm,
	arg_barra_obs a,
	prod_serv p
WHERE 
	pm.id_marca = ma.id_marca and
	pm.id_proveedor = a.id_tercero and
	ma.id_marca = i.id_marca AND
	p.id_item = i.id_item AND
	(i.ref_proveedor ILIKE '%'||a.clave||'%' OR 
	(COALESCE(i.ref_proveedor,'')||COALESCE(i.nombre,'')||COALESCE(ma.descripcion,'')||COALESCE(p.descripcion,'')||COALESCE(p.codigo,'')) ILIKE '%'||a.clave||'%') AND
	p.estado=true
ORDER BY
	ma.descripcion||' '||i.nombre;

DROP TABLE IF EXISTS aux_saldos_busqueda;
CREATE TEMP TABLE aux_saldos_busqueda AS
select
	i.id_prod_serv,
	i.id_bodega,
	sum(coalesce(i.entrada,0))-sum(coalesce(i.salida,0)) as saldo
from
	aux_productos_busqueda a
inner join
	inventarios i
on
	i.id_prod_serv = a.id_prod_serv
where
    i.id_bodega = a.id_bodega
group by 	
	i.id_prod_serv,
	i.id_bodega;

select
	p.codigo,
	p.descripcion||' - Saldo: '||coalesce(s.saldo,0)
from
	aux_productos_busqueda p
left join	
	aux_saldos_busqueda s
on
	p.id_prod_serv = s.id_prod_serv
order by
	p.nombre;