-- JBINS0022
--- Tabla auxiliar para creacion masiva de productos
DROP TABLE public.aux_actualizacion_precios_masiva; --?
CREATE TABLE public.aux_actualizacion_precios_masiva
(
  ndocumento bigint,
  codigo character varying(15),
  sap character varying(15),
  pventa1 double precision,
  pventa2 double precision,
  pventa3 double precision
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.aux_actualizacion_precios_masiva
  OWNER TO emaku;