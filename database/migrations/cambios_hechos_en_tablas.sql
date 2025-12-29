Cambios en tabla: documentos_standar

alter table documentos_standar add column activo boolean default true;
-- se marcan como activos los documentos que se usan en jbe
-- se quitan codigos_tipo que esten en mas de un documento

begin; update documentos_standar set nombre = 'PEDIDOS' where nombre ilike '%mostra%';

begin; update sentencia_sql set sentencia= replace(sentencia,'''MOSTRADOR''','''PEDIDOS''')where sentencia ilike '%''mostrador''%';


insert into enlace_centrocosto values(1,138);
insert into enlace_centrocosto values(2,241);
insert into enlace_centrocosto values(3,243);
insert into enlace_centrocosto values(4,245);