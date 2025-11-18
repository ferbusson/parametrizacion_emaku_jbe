drop table if exists puntos_tercero;
create table puntos_tercero
(
    id_puntos_tercero    serial      not null
        constraint puntos_tercero_pk
            primary key,
    ndocumento bigint,
    fecha   TIMESTAMP         not null,
    id_tercero integer      not null,
    puntos integer      not null,
    constraint fk_puntos_tercero_id_tercero
        foreign key (id_tercero) references general (id),
    constraint fk_puntos_tercero_ndocumento
        foreign key (ndocumento) references documentos (ndocumento)
);