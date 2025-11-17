-- Table: public.tmp_direcciones ?

DROP TABLE IF EXISTS public.tmp_direcciones;
CREATE TABLE public.tmp_direcciones
(
  id_char CHARACTER(25),
  descripcion character varying(50),
  direccion character varying(80) NOT NULL,
  id_dep character(3) NOT NULL,
  municipio character(3) NOT NULL
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.tmp_direcciones
  OWNER TO emaku;
