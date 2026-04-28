--- Tabla auxiliar para creacion masiva de productos
DROP TABLE public.creacion_productos_masiva; --?
CREATE TABLE public.creacion_productos_masiva
(
  ndocumento bigint,
  codigo character varying(15),
  referencia character varying(50),
  descripcion character varying(200),
  marca character varying(100),
  submarca character varying(100),
  linea character varying(60),
  grupo character varying(80),
  subgrupo character varying(80),
  iva integer,
  tipo_asiento_generico character varying(20),
  costo double precision,
  pventa1 double precision,
  pventa2 double precision,
  pventa3 double precision
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.creacion_productos_masiva
  OWNER TO emaku;