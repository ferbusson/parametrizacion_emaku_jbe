--SCSDE0003
DROP TABLE IF EXISTS aux_documento_electronico;
CREATE TEMP TABLE aux_documento_electronico AS
SELECT
	d.ndocumento,
	td.id_documento_electronico,
	CASE WHEN td.id_documento_electronico = 11 OR td.codigo_tipo = 'DO' THEN FALSE ELSE TRUE END AS redondear -- Los DOCUMENTO SOPORTE ELECTRONICO no manejan redondeo a 0, se usa en calculo de pventa
FROM
	documentos d,
	tipo_documento td
WHERE
	d.codigo_tipo = td.codigo_tipo AND	
	d.ndocumento = '?';

-- aux_articulo_plaza: Se usa para obtener la descripcion del servicio en el caso del documento soporte electronico
DROP TABLE IF EXISTS aux_articulo_plaza;
CREATE TEMP TABLE aux_articulo_plaza AS
SELECT
	ap.ndocumento,
	ap.id_prod_serv,
	ap.descripcion
 FROM
	aux_documento_electronico a,
	documentos d,
	articulo_plaza ap,
	tipo_documento td
 WHERE
	a.ndocumento = ap.ndocumento AND
	a.ndocumento = d.ndocumento AND
	d.codigo_tipo = td.codigo_tipo AND
	td.id_documento_electronico = 11; -- DOCUMENTO SOPORTE ELECTRONICO en tabla: documento_electronico

--

SELECT
	cant,
	stotal,
	pdescuento,
	--stotal,
	CASE WHEN piva = 0 AND (id_asiento_generico = 5 OR id_asiento_generico = 10) THEN ROUND(stotal::NUMERIC,0) ELSE stotal END AS stotal,
	pventa,
	--vdescuento, esta era la orignal
	--CASE WHEN piva = 0 AND (id_asiento_generico = 5 OR id_asiento_generico = 10) THEN ROUND(vdescuento::NUMERIC,0) ELSE vdescuento END AS vdescuento,
	--vdescuento sin iva
	CASE WHEN piva = 0 AND (id_asiento_generico = 5 OR id_asiento_generico = 10) THEN ROUND(vdescuento::NUMERIC,0) ELSE ROUND((vdescuento/(1+(piva/100)))::NUMERIC,2) END AS vdescuento,
	--neto,
	CASE WHEN piva = 0 AND (id_asiento_generico = 5 OR id_asiento_generico = 10) THEN ROUND(neto::NUMERIC,0) ELSE neto END AS neto,
	--viva,
	CASE WHEN piva = 0 AND (id_asiento_generico = 5 OR id_asiento_generico = 10) THEN CASE WHEN ROUND(viva) = 1 OR ROUND(viva) = 0 THEN 0 ELSE ROUND(viva) END ELSE CASE WHEN id_asiento_generico = 13 THEN 0 ELSE viva END END AS viva,
	piva,
	codigo,
	TRIM(referencia) AS referencia,
	descripcion,
	vunitario_bolsa,
	total_bolsas
FROM
	(SELECT
		cant,
		case when id_documento_electronico = 11 then
			round(pventa_sin_iva::numeric,0)
		else
			pventa_sin_iva
		end AS pventa,
		pdescuento,
		case when id_documento_electronico = 11 then
			round(stotal::numeric,0)
		else
			stotal
		end as stotal,
		vdescuento,
		case when id_documento_electronico = 11 then
			ROUND(((cant*pventa-vdescuento)/(1+(piva/100)))::NUMERIC,0)
		else
			ROUND(((cant*pventa-vdescuento)/(1+(piva/100)))::NUMERIC,2) end AS neto,
		case when id_documento_electronico = 11 then
			ROUND((cant*pventa-vdescuento)::NUMERIC,2)-ROUND(((cant*pventa-vdescuento)/(1+(piva/100)))::NUMERIC,0)
		else
			ROUND((cant*pventa-vdescuento)::NUMERIC,2)-ROUND(((cant*pventa-vdescuento)/(1+(piva/100)))::NUMERIC,2) end AS viva,
		piva,
		codigo,
		referencia,
		descripcion,
		orden,
		id_asiento_generico,
		vunitario_bolsa,
		vunitario_bolsa*cant as total_bolsas
	FROM
		(SELECT 
		    cant,
		    case when coalesce(dp.porcentajebp,-1) < 0 then dp.pventa else round((dp.pventa - (dp.inc*(coalesce(dp.porcentajebp,-1)/100.0)))::numeric,2) end as pventa,
		    COALESCE(dp.descuento1,0) as pdescuento,
		    -- pventa sin iva
		    CASE WHEN a.redondear THEN 
		    	case when coalesce(coalesce(dp.porcentajebp,-1),-1) < 0 then
		    		round((pventa/(1+(dp.iva/100)))::numeric,2)
		    	else
		    		round((round((dp.pventa - (dp.inc*(coalesce(dp.porcentajebp,-1)/100.0)))::numeric,2)/(1+(dp.iva/100)))::numeric,2)
		    	end
		    ELSE 
		    	case when coalesce(dp.porcentajebp,-1) < 0 then
		    		round((pventa/(1+(dp.iva/100)))::numeric,2) 
		    	else
		    		round((round((dp.pventa - (dp.inc*(coalesce(dp.porcentajebp,-1)/100.0)))::numeric,2)/(1+(dp.iva/100)))::numeric,2)
		    	end
		    END AS pventa_sin_iva, --pventa sin iva	    
		 	-- stotal
		 	CASE WHEN a.redondear THEN 
		 		case when coalesce(dp.porcentajebp,-1) < 0 then
			 		round(((cant*pventa)/(1+(dp.iva/100)))::numeric,0) 
			 	else
			 		round(((cant*round((dp.pventa - (dp.inc*(coalesce(dp.porcentajebp,-1)/100.0)))::numeric,2))/(1+(dp.iva/100)))::numeric,0)
			 	end
			 ELSE 
			 	case when coalesce(dp.porcentajebp,-1) < 0 then
				 	round(((cant*pventa)/(1+(dp.iva/100)))::numeric,2) 
				else
					round(((cant*round((dp.pventa - (dp.inc*(coalesce(dp.porcentajebp,-1)/100.0)))::numeric,2))/(1+(dp.iva/100)))::numeric,2)
				end
			END AS stotal, --stotal	    		 

		 
		    round(((cant*pventa)*COALESCE(dp.descuento1,0)/100)::numeric,0) as vdescuento,
		    dp.iva as piva,
		    trim(ps.codigo) AS codigo,
		    i.ref_proveedor AS referencia,		    
		 	COALESCE(ap.descripcion,i.nombre) AS descripcion,
		    orden,
		    ps.id_asiento_generico,
		    case when dp.porcentajebp is not null and dp.porcentajebp >= 0  then round((dp.inc*(dp.porcentajebp/100.0))::numeric,2) else 0 end as vunitario_bolsa,
		    a.id_documento_electronico
		FROM 		 	
		    prod_serv ps,
		    item i,
		 	aux_documento_electronico a,
		    datos_prod dp
		LEFT OUTER JOIN 
			aux_articulo_plaza ap
		ON
			dp.ndocumento = ap.ndocumento AND
			dp.id_prod_serv = ap.id_prod_serv
		WHERE 
		    ps.id_item = i.id_item AND
		    ps.id_asiento_generico != 12 AND -- SE ELIMINA PRODUCTOS EXCLUIDOS
		    ps.codigo!='0000' AND --- SE ELIMINA LA BOLSA PLASTICA YA QUE ESTA TIENE OTRO TRATAMIENTO
		    ps.id_prod_serv=dp.id_prod_serv AND
		    dp.ndocumento=a.ndocumento) AS f
		   ) AS f
ORDER BY
	orden ASC;