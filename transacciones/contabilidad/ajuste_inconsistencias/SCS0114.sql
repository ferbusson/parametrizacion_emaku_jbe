-- SCS0114  
/*drop table if exists aux_productos_que_necesitan_recosteo;
create temp table aux_productos_que_necesitan_recosteo as
WITH
-- Services excluded from inventory checks (id_tipo_prod_serv = '002')
services AS (
    SELECT id_prod_serv FROM prod_serv WHERE id_tipo_prod_serv = '002'
)
,

last_row AS (
    SELECT DISTINCT ON (i.id_prod_serv)
        i.id_prod_serv,
        i.pinventario AS last_pinv,
        i.saldo       AS last_saldo
    FROM inventarios i
    join
    	documentos d
    on
    	i.ndocumento = d.ndocumento
    where
    	d.estado and
    	i.fecha >= '2026-07-01 00:00:00'
    and i.id_prod_serv NOT IN (SELECT s.id_prod_serv FROM services s)
    ORDER BY i.id_prod_serv, i.fecha DESC, i.orden DESC
)
,

bad_vsaldo AS (
    SELECT i.id_prod_serv
    FROM inventarios i
    join
    	documentos d
    on
    	i.ndocumento = d.ndocumento    	
    where
    	d.estado and
    	i.fecha >= '2026-07-01 00:00:00'
    and i.id_prod_serv NOT IN (SELECT s.id_prod_serv FROM services s)
      AND i.saldo       IS NOT NULL AND i.saldo       != 0
      AND i.pinventario IS NOT NULL AND i.pinventario != 0
      AND ABS(i.valor_saldo - i.saldo * i.pinventario) > 10.0
    GROUP BY i.id_prod_serv
),

bad_anulados AS (
    SELECT id_prod_serv
    FROM (
        SELECT i.id_prod_serv,
               d.estado,
               i.saldo,
               LAG(i.saldo) OVER (
                   PARTITION BY i.id_bodega, i.id_prod_serv
                   ORDER BY i.fecha, i.orden
               ) AS prev_saldo
        FROM inventarios i
        JOIN documentos d ON i.ndocumento = d.ndocumento
        WHERE 
        	i.fecha >= '2026-07-01 00:00:00'
        	and id_prod_serv NOT IN (SELECT id_prod_serv FROM services)
    ) sub
    WHERE estado = false
      AND prev_saldo IS NOT NULL
      AND ABS(saldo - prev_saldo) > 0.005
    GROUP BY id_prod_serv
),

bad_exits AS (
    SELECT DISTINCT i.id_prod_serv
    FROM inventarios i
    JOIN documentos d ON i.ndocumento = d.ndocumento
    where
    	i.fecha >= '2026-07-01 00:00:00'
    	and id_prod_serv NOT IN (SELECT id_prod_serv FROM services)
      AND d.estado = true
      AND i.salida IS NOT NULL AND i.salida != 0
      AND (i.valor_sal IS NULL OR i.valor_sal = 0)
),

neg_pinv AS (
    SELECT DISTINCT i.id_prod_serv
    FROM inventarios i
    JOIN documentos d ON i.ndocumento = d.ndocumento
    where
    	i.fecha >= '2026-07-01 00:00:00'
    	and id_prod_serv NOT IN (SELECT id_prod_serv FROM services)
      AND 
      d.estado = true
      AND i.pinventario IS NOT NULL AND i.pinventario < 0
)

SELECT
    lr.id_prod_serv,
    (CASE WHEN bv.id_prod_serv IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN ba.id_prod_serv IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN be.id_prod_serv IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN np.id_prod_serv IS NOT NULL THEN 1 ELSE 0 END +
     CASE WHEN lr.last_saldo < 0                          THEN 1 ELSE 0 END +
     CASE WHEN lr.last_pinv  < 0                          THEN 1 ELSE 0 END +
     CASE WHEN lr.last_saldo != 0 AND lr.last_pinv = 0   THEN 1 ELSE 0 END
    ) AS severity
FROM last_row lr
LEFT JOIN bad_vsaldo   bv ON lr.id_prod_serv = bv.id_prod_serv
LEFT JOIN bad_anulados ba ON lr.id_prod_serv = ba.id_prod_serv
LEFT JOIN bad_exits    be ON lr.id_prod_serv = be.id_prod_serv
LEFT JOIN neg_pinv     np ON lr.id_prod_serv = np.id_prod_serv
WHERE
    bv.id_prod_serv IS NOT NULL OR
    ba.id_prod_serv IS NOT NULL OR
    be.id_prod_serv IS NOT NULL OR
    np.id_prod_serv IS NOT NULL OR
    lr.last_saldo < 0           OR
    lr.last_pinv  < 0           OR
    (lr.last_saldo != 0 AND lr.last_pinv = 0)
ORDER BY severity DESC, lr.id_prod_serv;
*/
--
drop table if exists aux_productos_que_necesitan_recosteo;
create temp table aux_productos_que_necesitan_recosteo as
select
	foo.id_prod_serv,
	1 as severity
from
	(select
		ps.id_prod_serv
	from
		prod_serv ps
	where
		ps.id_prod_serv in 
		(1727,1029)
	) as foo;
--


drop table if exists aux_productos_recostear;
create temp table aux_productos_recostear as
SELECT
    foo.id_bodega,
    foo.id_prod_serv    
FROM
(SELECT DISTINCT
    NULL,
    foo.id_bodega,
    foo.id_prod_serv,
    0,
    0
FROM
    inventarios foo
inner join
    aux_productos_que_necesitan_recosteo a
on
    foo.id_prod_serv = a.id_prod_serv
where
    a.severity >= 1
    ) as foo
ORDER BY
    case WHEN 
            foo.id_bodega = 140 THEN 10000  --pedidos en jbe la mandamos al final
        ELSE 
            ROW_NUMBER() OVER(ORDER BY foo.id_bodega) 
        end;

drop table if exists aux_productos_sin_saldo_inicial_julio;
create temp table aux_productos_sin_saldo_inicial_julio as
select distinct
	a.id_prod_serv
from
	aux_productos_recostear a
where
	not exists (select 1 from copia_inventarios_saldo_inicial_01julio2026 i where i.id_prod_serv = a.id_prod_serv);


drop table if exists aux_valores_productos_sin_saldo_inicial_julio;
create temp table aux_valores_productos_sin_saldo_inicial_julio as
SELECT DISTINCT ON(i.id_prod_serv)
    i.id_prod_serv,
    i.fecha::date AS fecha_ult_compra,
    i.id_bodega,
    i.entrada,
    i.valor_ent AS pinventario,
    i.saldo,
    i.valor_saldo
FROM
    documentos d,
    inventarios i,
    aux_productos_sin_saldo_inicial_julio lp
WHERE
    d.ndocumento = i.ndocumento AND
    d.estado AND
    d.codigo_tipo IN ('EA','RC','IM','AT','IP','AF','AO','IJ') AND
    lp.id_prod_serv = i.id_prod_serv and
    d.fecha >= '2026-07-01 00:00:00'
ORDER BY
    i.id_prod_serv,
    i.fecha asc;

        
--
SELECT
    '2026-07-01 00:00:00'::timestamp fecha_corte,
    a.id_bodega,
    a.id_prod_serv,
    coalesce(coalesce(i.saldo,ea.saldo),0) as saldo,
    coalesce(coalesce(i.valor_saldo,ea.valor_saldo),0) as valor_saldo
FROM
  	aux_productos_recostear a  
left join
	copia_inventarios_saldo_inicial_01julio2026 i
on
  i.id_prod_serv = a.id_prod_serv
  and i.id_bodega = a.id_bodega
left join
	aux_valores_productos_sin_saldo_inicial_julio ea
on
	ea.id_prod_serv = a.id_prod_serv
  and ea.id_bodega = a.id_bodega
ORDER BY
    i.id_bodega,
    i.id_prod_serv;