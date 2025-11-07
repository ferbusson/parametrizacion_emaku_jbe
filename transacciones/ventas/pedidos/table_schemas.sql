\d prod_serv
+---------------------+-----------------------+-------------------------------------------------------------------+
| Column              | Type                  | Modifiers                                                         |
|---------------------+-----------------------+-------------------------------------------------------------------|
| id_prod_serv        | integer               |  not null default nextval('prod_serv_id_prod_serv_seq'::regclass) |
| codigo              | character(14)         |  not null                                                         |
| id_tipo_prod_serv   | character(3)          |  not null                                                         |
| estado              | boolean               |  not null                                                         |
| codigo_b            | character varying(14) |                                                                   |
| descripcion         | character varying(50) |                                                                   |
| id_asiento_generico | bigint                |                                                                   |
| iva                 | double precision      |  not null                                                         |
| pcosto              | double precision      |  not null                                                         |
| comision            | real                  |  not null default 0                                               |
| id_item             | bigint                |  not null                                                         |
| id_talla            | integer               |                                                                   |
| id_color            | integer               |                                                                   |
+---------------------+-----------------------+-------------------------------------------------------------------+
Indexes:
    "prod_serv_pkey" PRIMARY KEY, btree (id_prod_serv)
    "prod_serv_codigo_key" UNIQUE CONSTRAINT, btree (codigo)
    "prod_serv_codigo_idx" btree (codigo)
    "prod_serv_id_item_idx" btree (id_item)
    "prod_serv_id_prod_serv_idx" btree (id_prod_serv)
Foreign-key constraints:
    "$2" FOREIGN KEY (id_tipo_prod_serv) REFERENCES tipo_prod_serv(id_tipo_prod_serv)
    "$3" FOREIGN KEY (id_asiento_generico) REFERENCES asientos_genericos(id_asiento_generico)
    "prod_serv_id_color_fkey" FOREIGN KEY (id_color) REFERENCES colores(id_color)
    "prod_serv_id_talla_fkey" FOREIGN KEY (id_talla) REFERENCES tallas(id_talla)
    "prod_serv_item_fk" FOREIGN KEY (id_item) REFERENCES item(id_item)
Referenced by:
    TABLE "combo_prod_serv" CONSTRAINT "combo_prod_serv_id_cb_prod_serv_fkey" FOREIGN KEY (id_cb_prod_serv) REFERENCES prod_serv(id_prod_serv)
    TABLE "combo_prod_serv" CONSTRAINT "combo_prod_serv_id_prod_serv_fkey" FOREIGN KEY (id_prod_serv) REFERENCES prod_serv(id_prod_serv)
    TABLE "datos_ajuste_inventario" CONSTRAINT "datos_ajuste_inventario_id_prod_serv_fkey" FOREIGN KEY (id_prod_serv) REFERENCES prod_serv(id_prod_serv)
    TABLE "datos_grupo" CONSTRAINT "$2" FOREIGN KEY (id_prod_serv) REFERENCES prod_serv(id_prod_serv)
    TABLE "datos_prod" CONSTRAINT "$3" FOREIGN KEY (id_prod_serv) REFERENCES prod_serv(id_prod_serv)
    TABLE "datos_sgrupo" CONSTRAINT "datos_sgrupo_id_prod_serv_fkey" FOREIGN KEY (id_prod_serv) REFERENCES prod_serv(id_prod_serv)
    TABLE "enlace_producto_tarifa_bolsa_eco" CONSTRAINT "enlace_producto_tarifa_bolsa_eco_prod_serv_fk" FOREIGN KEY (id_prod_serv) REFERENCES prod_serv(id_prod_serv)
    TABLE "inventarios" CONSTRAINT "$1" FOREIGN KEY (id_prod_serv) REFERENCES prod_serv(id_prod_serv)
    TABLE "inventarios_documentos_rechazados" CONSTRAINT "$1" FOREIGN KEY (id_prod_serv) REFERENCES prod_serv(id_prod_serv)
    TABLE "libro_auxiliar" CONSTRAINT "$4" FOREIGN KEY (id_prod_serv) REFERENCES prod_serv(id_prod_serv)
    TABLE "libro_auxiliar_documentos_rechazados" CONSTRAINT "$4" FOREIGN KEY (id_prod_serv) REFERENCES prod_serv(id_prod_serv)
    TABLE "libro_auxiliar_niifs" CONSTRAINT "$4" FOREIGN KEY (id_prod_serv) REFERENCES prod_serv(id_prod_serv)
    TABLE "libro_temp" CONSTRAINT "$4" FOREIGN KEY (id_prod_serv) REFERENCES prod_serv(id_prod_serv)
    TABLE "obsequios_promociones" CONSTRAINT "obsequios_promosiones_id_prod_serv_fkey" FOREIGN KEY (id_prod_serv) REFERENCES prod_serv(id_prod_serv)
    TABLE "pendiente" CONSTRAINT "pendiente_id_prod_serv_fkey" FOREIGN KEY (id_prod_serv) REFERENCES prod_serv(id_prod_serv)
    TABLE "pventa" CONSTRAINT "$2" FOREIGN KEY (id_prod_serv) REFERENCES prod_serv(id_prod_serv)
    TABLE "stocks" CONSTRAINT "$1" FOREIGN KEY (id_prod_serv) REFERENCES prod_serv(id_prod_serv)
    TABLE "unidades_prod" CONSTRAINT "$1" FOREIGN KEY (id_prod_serv) REFERENCES prod_serv(id_prod_serv)


\d item
+-----------------+-----------------------------+----------------------------------------------------------+
| Column          | Type                        | Modifiers                                                |
|-----------------+-----------------------------+----------------------------------------------------------|
| id_linea        | integer                     |  not null default nextval('item_id_linea_seq'::regclass) |
| id_grupo        | integer                     |  default nextval('item_id_grupo_seq'::regclass)          |
| id_sgrupo       | integer                     |  default nextval('item_id_sgrupo_seq'::regclass)         |
| id_item         | integer                     |  not null default nextval('item_id_item_seq'::regclass)  |
| id_marca        | integer                     |                                                          |
| id_presentacion | integer                     |                                                          |
| ref_proveedor   | character(50)               |                                                          |
| id_submarca     | integer                     |                                                          |
| nombre          | character varying(100)      |                                                          |
| descripcion_web | text                        |                                                          |
| created_at      | timestamp without time zone |  not null default now()                                  |
| updated_at      | timestamp without time zone |  not null default now()                                  |
+-----------------+-----------------------------+----------------------------------------------------------+
Indexes:
    "item_pkey" PRIMARY KEY, btree (id_item)
    "item_id_marca_ref_proveedor_nombre_key" UNIQUE CONSTRAINT, btree (id_marca, ref_proveedor, nombre)
    "item_id_item_idx" btree (id_item)
    "item_id_linea_idx" btree (id_linea)
Foreign-key constraints:
    "item_id_marca_fkey" FOREIGN KEY (id_marca) REFERENCES marcas(id_marca)
    "item_id_presentacion_fkey" FOREIGN KEY (id_presentacion) REFERENCES presentacion(id_presentacion)
    "item_id_submarca_fkey" FOREIGN KEY (id_submarca) REFERENCES submarcas(id_submarca)
Referenced by:
    TABLE "agrupamiento_categorias_mercadolibre" CONSTRAINT "id_item" FOREIGN KEY (id_item) REFERENCES item(id_item)
    TABLE "control_traslado_items" CONSTRAINT "control_traslado_items_id_item_fkey" FOREIGN KEY (id_item) REFERENCES item(id_item)
    TABLE "images" CONSTRAINT "images_id_item_fkey" FOREIGN KEY (id_item) REFERENCES item(id_item)
    TABLE "items_promocion" CONSTRAINT "items_promosion_id_item_fkey" FOREIGN KEY (id_item) REFERENCES item(id_item)
    TABLE "ml_ficha_tecnica_descriptivos" CONSTRAINT "ml_ficha_tecnica_descriptivos_id_item_fkey" FOREIGN KEY (id_item) REFERENCES item(id_item)
    TABLE "ml_ficha_tecnica_selecciones" CONSTRAINT "ml_ficha_tecnica_selecciones_id_item_fkey" FOREIGN KEY (id_item) REFERENCES item(id_item)
    TABLE "ml_ficha_tecnica_unds" CONSTRAINT "ml_ficha_tecnica_unds_id_item_fkey" FOREIGN KEY (id_item) REFERENCES item(id_item)
    TABLE "ml_garantias" CONSTRAINT "ml_garantias_id_item_fkey" FOREIGN KEY (id_item) REFERENCES item(id_item)
    TABLE "ml_preguntas" CONSTRAINT "ml_preguntas_id_item_fkey" FOREIGN KEY (id_item) REFERENCES item(id_item)
    TABLE "ml_publicaciones" CONSTRAINT "ml_publicaciones_id_item_fkey" FOREIGN KEY (id_item) REFERENCES item(id_item)
    TABLE "prod_serv" CONSTRAINT "prod_serv_item_fk" FOREIGN KEY (id_item) REFERENCES item(id_item)
Triggers:
    set_timestamp BEFORE UPDATE ON item FOR EACH ROW EXECUTE FUNCTION trigger_set_timestamp()


\d pventa

+--------------+------------------+---------------------+
| Column       | Type             | Modifiers           |
|--------------+------------------+---------------------|
| id_catalogo  | bigint           |  not null           |
| id_prod_serv | bigint           |  not null           |
| pventa       | double precision |  not null           |
| id_lista     | integer          |  not null default 1 |
+--------------+------------------+---------------------+
Indexes:
    "pventa_pkey" PRIMARY KEY, btree (id_prod_serv, id_catalogo, id_lista)
    "unique_id_prod_serv_id_catalogo_id_list" UNIQUE CONSTRAINT, btree (id_prod_serv, id_catalogo, id_lista)
Foreign-key constraints:
    "$1" FOREIGN KEY (id_catalogo) REFERENCES catalogo_pventa(id_catalogo)
    "$2" FOREIGN KEY (id_prod_serv) REFERENCES prod_serv(id_prod_serv)
    "fk_listas_pventa_id_lista" FOREIGN KEY (id_lista) REFERENCES listas_pventa(id_lista) ON UPDATE CASCADE ON DELETE RESTRICT


\d inventarios
+--------------+-----------------------------+--------------------------------------------------------------+
| Column       | Type                        | Modifiers                                                    |
|--------------+-----------------------------+--------------------------------------------------------------|
| orden        | integer                     |  not null default nextval('inventarios_orden_seq'::regclass) |
| fecha        | timestamp without time zone |  not null                                                    |
| id_prod_serv | bigint                      |  not null                                                    |
| id_bodega    | bigint                      |  not null                                                    |
| ndocumento   | bigint                      |  not null                                                    |
| pinventario  | double precision            |  not null                                                    |
| entrada      | double precision            |                                                              |
| valor_ent    | double precision            |                                                              |
| salida       | double precision            |                                                              |
| valor_sal    | double precision            |                                                              |
| saldo        | double precision            |  not null                                                    |
| valor_saldo  | double precision            |  not null                                                    |
+--------------+-----------------------------+--------------------------------------------------------------+
Indexes:
    "inventarios_orden_key" UNIQUE CONSTRAINT, btree (orden)
    "inventarios_orden_index" btree (orden)
Foreign-key constraints:
    "$1" FOREIGN KEY (id_prod_serv) REFERENCES prod_serv(id_prod_serv)
    "$2" FOREIGN KEY (id_bodega) REFERENCES general(id)
    "$3" FOREIGN KEY (ndocumento) REFERENCES documentos(ndocumento)


