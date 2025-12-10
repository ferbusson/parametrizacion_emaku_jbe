SELECT
	consecutivo_envio
FROM	
	envio_webservice
WHERE
	consecutivo_envio = (SELECT MAX(consecutivo_envio) FROM envio_webservice)