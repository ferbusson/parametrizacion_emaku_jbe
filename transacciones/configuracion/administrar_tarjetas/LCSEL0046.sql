DROP TABLE IF EXISTS tmp_tarjetasdc;
CREATE TABLE tmp_tarjetasdc(
	nombre CHARACTER VARYING(50),
	tipo CHARACTER VARYING(100),
	prte_fuente DOUBLE PRECISION,
	prte_IVA DOUBLE PRECISION,
	comision FLOAT8,
	visible BOOLEAN,
	id_tercero_banco CHARACTER(15),
	id_banco bigint,
	id_cta_rfuente bigint,
	id_cta_rtiva bigint,
	id_cta_comision bigint
	);