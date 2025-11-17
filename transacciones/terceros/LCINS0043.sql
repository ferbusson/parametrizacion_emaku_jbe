-- Table: public.tmp_telefonos ?

DROP TABLE IF EXISTS public.tmp_telefonos;
CREATE TABLE public.tmp_telefonos
(
  id_char CHARACTER(25),
  descripcion character varying(50),
  numero character varying(30) NOT NULL,
  id_dep character(3) NOT NULL,
  municipio character(3) NOT NULL,
  clase CHARACTER(2)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.tmp_telefonos
  OWNER TO emaku;
