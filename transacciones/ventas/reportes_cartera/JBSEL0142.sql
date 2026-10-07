--JBSEL0142
drop table if exists aux_listado_empleados;
create temp table aux_listado_empleados as
SELECT 
	i.id,
	i.sigla 
FROM 
	info_empleado i
WHERE
	i.estado='ACT';
	
select
	id,
	sigla
from
	aux_listado_empleados
ORDER BY
	-- Part 1: Separate numbers from text (0 puts numbers first, 1 puts text last)
  CASE WHEN sigla ~ '^[0-9]+$' THEN 0 ELSE 1 END,
  -- Part 2: Sort numbers numerically
  CASE WHEN sigla ~ '^[0-9]+$' THEN substring(sigla from '^[0-9]+$')::bigint END,
  -- Part 3: Sort the remaining text fields alphabetically
  sigla;

