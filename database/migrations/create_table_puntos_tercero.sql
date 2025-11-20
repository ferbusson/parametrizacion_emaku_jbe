-- public.puntos_tercero definition

-- Drop table

-- DROP TABLE public.puntos_tercero;

CREATE TABLE public.puntos_tercero (
	id_puntos_tercero serial4 NOT NULL,
	ndocumento int8 NULL,
	fecha timestamp NOT NULL,
	id_tercero int4 NOT NULL,
	puntos int4 NOT NULL,
	CONSTRAINT puntos_tercero_pk PRIMARY KEY (id_puntos_tercero),
	CONSTRAINT fk_puntos_tercero_id_tercero FOREIGN KEY (id_tercero) REFERENCES public."general"(id),
	CONSTRAINT fk_puntos_tercero_ndocumento FOREIGN KEY (ndocumento) REFERENCES public.documentos(ndocumento)
);

-- Table Triggers

create trigger trg_calcular_saldo_acumulado_puntos before
insert
    on
    public.puntos_tercero for each row execute function calcular_saldo_acumulado_puntos();

comment on table puntos_tercero is 'Tabla que almacena los puntos generados o redimidos de un tercero con calculo de saldo de puntos';
