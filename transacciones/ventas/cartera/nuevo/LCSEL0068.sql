SELECT
	a.id_bodega_ppal,
	a.id_bodega_sep,
	d.codigo_tipo,
	a.id_centrocosto,
	TRIM(a.nombre) AS nombre,
	TRIM(a.nombre||' / '||a.direccion) AS direccion,
	TRIM('Tel: '||a.telefono) AS telefono,
	TRIM(a.email) AS email,
	TRIM(a.ciudad) AS ciudad
FROM
	administracion_sucursales a,
	documentos_sucursales d,
	asignacion_usuario_sucursal au,
	usuarios u
WHERE
	a.id_administracion_sucursales = d.id_administracion_sucursales AND
	au.id_administracion_sucursales = a.id_administracion_sucursales AND
	d.id_transaccion = '193' AND
	au.id = u.id_usuario AND
	u.login = '?';
