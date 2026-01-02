SELECT
'<!DOCTYPE html>
<html lang="en">
<head/>
    <meta charset="UTF-8">
    <title>Mi primer archivo HTML</title>
    <style type="text/css">
        body {
            font-family: Helvetica;
            }
        strong {
            background-color: #FFAAAA;
        }
    </style>
</head>
<body>
Cordial Saludo,<br><br>'
||trim(COALESCE(gt.nombre1,'')||' '||COALESCE(gt.nombre2,'')||' '||COALESCE(gt.apellido1,'')||' '||COALESCE(gt.apellido2,'')||' '||COALESCE(gt.razon_social,''))||'<br><br>
<table>
<tr>
    <td>TIPO:</td><td>Nota Crédito de la Factura de Venta Electrónica</td>
</tr>
<tr>
    <td>Número:</td><td>'||COALESCE(rf.prefijo,d.codigo_tipo)||' - '||d.numero::BIGINT||'</td>
</tr>
<tr>
    <td>Valor:</td><td>$'||to_char(dd.valor,'999,999,999.99')||'</td>
</tr>
<tr>
    <td>Fecha Emision:</td><td>'||d.fecha::DATE||'</td>
</tr>
</table>
<p>El documento electrónico adjunto se entenderá tácitamente aceptado si no es rechazado dentro de los tres días hábiles siguientes a la recepción del presente correo,
de conformidad con lo establecido en el artículo 2.2.2.53.5 del Decreto 1349 de 2016 y el artículo 773 del Código de Comercio.</p>
<p>En caso de rechazo, por favor remitir su solicitud con la respectiva justificación al correo: <a href="#">secretaria@javierbenavideserazosas.com</a></p>
<p>Se adjunta Representación gráfica y archivo XML</p>
<p>Atentamente:<br><br>
<b>'||g.razon_social||'</b><br>
NIT: '||g.id_char||'-'||g.dv||'<br>
Teléfono: (2)'||tel.numero||'<br>
</p>
</body>
</html>' AS body
FROM
	general g,
	tercero_def t,
	datos_documento dd,
	(SELECT 
		id,
		MAX(id_telefono) AS id_telefono
	FROM
		telefonos
	GROUP BY
		id) AS foo,
	telefonos tel,
	general gt,
	documentos d
LEFT OUTER JOIN
	resolucion_documento rd
ON
	d.ndocumento = rd.ndocumento
LEFT OUTER JOIN
	resolucion_facturacion rf
ON
	rd.id_resolucion_facturacion = rf.id_resolucion_facturacion
WHERE
	d.ndocumento = '?' AND
	d.ndocumento=t.ndocumento AND
	t.id=gt.id AND
	dd.ndocumento = d.ndocumento AND
	g.id = 1 AND
	g.id = foo.id AND
	foo.id_telefono = tel.id_telefono;