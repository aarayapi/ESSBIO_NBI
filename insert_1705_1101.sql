-- FUNCTION: owd.insert_1705_1102(date, date)

-- DROP FUNCTION IF EXISTS owd.insert_1705_1102(date, date);

CREATE OR REPLACE FUNCTION owd.insert_1705_1102(
	fecha_inicio date,
	fecha_fin date)
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE 
	punto record;	
	
	codigoproceso integer;
	codigoarchivo integer;
	rut character varying(20);
    periodo integer;
	
	
    codigo_sistema_siss integer; --1
    nombre_conduccion character varying(255); --2
    id_tramo_conectado character varying(255); --3
    anio_instalacion integer; --4
	lifecyclestatus integer; --5
	--tipo_tramo integer; --6
 	tipo_operacion integer; --7
    diameter integer; --8	
	material integer; --9
	otromaterial character varying(100); --10
	presion_maxima_trabajo numeric; --11
    measuredlength numeric; --12
    profundidad_media_tramo numeric; --13
    --slope numeric;--14
    tipo_terreno integer; --15
    porcentaje_napa numeric; --16
    paralelo integer; --17
	ownedby smallint;
	
	codigo_obra character varying(255);
	gdb_from_date  timestamp without time zone;
	assetid character varying(100);
	
    codigo_sistema_siss2 integer; --1
    nombre_conduccion2 character varying(255); --2
    id_tramo_conectado2 character varying(255); --3
    anio_instalacion2 integer; --4
	lifecyclestatus2 integer; --5
	--tipo_tramo2 integer; --6
 	tipo_operacion2 integer; --7
    diameter2 integer; --8	
	material2 integer; --9 
	otromaterial2 character varying(100); --10	
	presion_maxima_trabajo2 numeric; --11
    measuredlength2 numeric; --12
    profundidad_media_tramo2 numeric; --13
    --slope2 numeric;--14
    tipo_terreno2 integer; --15
    porcentaje_napa2 numeric; --16
    paralelo2 integer; --17
	ownedby2 smallint;	

	codigo_obra2 character varying(255);
	gdb_from_date2  timestamp without time zone;
	assetid2 character varying(100);

	gdb_archive_oid integer;
	gdb_archive_oid2 integer;
	proyecto_informado_siss character varying(100);
	proyecto_informado_siss2 character varying(100);
	cantidad integer;
	correlativo smallint;
	resultado character varying(100);
	cuenta2 integer;	
BEGIN

codigoproceso :=  5;
codigoarchivo := 1705; 
--rut := '96963440';
periodo := ((date_part('year'::text, CURRENT_DATE) - 1::double precision) || '12')::integer;

resultado   := '';
correlativo := 1;
cantidad := 0;
cuenta2 := 0;

INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", 
						   "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)										
	SELECT  '5', '1705',         
		CASE wdsb.ownedby
            WHEN 103 THEN '76833300'::text
            WHEN 104 THEN '96963440'::text
            ELSE NULL::text
        END AS rut1, ((date_part('year'::text, CURRENT_DATE) - 1::double precision) || '12')::integer AS periodo,
		wdsb.proyecto_informado_siss, wdsb.codigo_sistema_siss, 1102, wdsb.codigo_obra, wdsb.id_tramo_conectado, 11, round(wdsb.measuredlength,2) ,
		round(sde.st_length(wdsb.shape)::numeric,2), wdsb.gdb_from_date, wdsb.gdb_archive_oid			
	FROM owd.vmt_1705_waterline_sb_dbl wdsb WHERE (wdsb.assetgroup = 1 OR wdsb.assettype = 1)
	AND wdsb.proyecto_informado_siss is not null AND round(wdsb.measuredlength,2) <> round(sde.st_length(wdsb.shape)::numeric,2)
	AND wdsb.creationdate < fecha_inicio AND wdsb.lastupdate > fecha_inicio;	

SELECT count(*) into cantidad
	FROM owd.vmt_1705_waterline_dbl vmt WHERE  vmt.assetgroup = 1 OR vmt.assettype = 1 AND vmt.assetid  in 
	(select distinct vmt_1.assetid from owd.vmt_1705_waterline_dbl vmt_1 WHERE vmt_1.creationdate < fecha_inicio);
	 
if cantidad > 0 then
   	FOR punto IN SELECT * 
	FROM owd.vmt_1705_waterline_dbl  vmt WHERE  vmt.assetgroup = 1 OR vmt.assettype = 1 AND vmt.assetid  in 
	(select distinct vmt_1.assetid from owd.vmt_1705_waterline_dbl vmt_1 WHERE vmt_1.creationdate < fecha_inicio) 
	order by vmt.ownedby, vmt.assetid, vmt.gdb_from_date LOOP
	
		cuenta2 := cuenta2 + 1;	 

		
		IF correlativo = 1 then
			correlativo := correlativo + 1;
			
			codigo_sistema_siss := punto.codigo_sistema_siss; --1
			nombre_conduccion := punto.nombre_conduccion; --2
			id_tramo_conectado := punto.id_tramo_conectado; --3
			anio_instalacion := punto.anio_instalacion; --4
			lifecyclestatus := punto.lifecyclestatus; --5
			--tipo_tramo := punto.tipo_tramo; --6
			tipo_operacion := punto.tipo_operacion; --6
			diameter := punto.diameter; --7
			material := punto.material; --8
			otromaterial = punto.material; --9
			presion_maxima_trabajo := punto.presion_maxima_trabajo; --10
			measuredlength := punto.measuredlength; --11
			profundidad_media_tramo := punto.profundidad_media_tramo; --12
			--slope := punto.slope;--13
			tipo_terreno := punto.tipo_terreno; --13
			porcentaje_napa := punto.porcentaje_napa; --14
			paralelo := punto.paralelo; --15
			codigo_obra := punto.codigo_obra;
			ownedby := punto.ownedby;
			
			
			assetid = punto.assetid;
			gdb_archive_oid = punto.gdb_archive_oid;			
			gdb_from_date := punto.gdb_from_date;
			proyecto_informado_siss := punto.proyecto_informado_siss;

			
		ELSIF correlativo > 1 THEN
			IF correlativo = 2 THEN

				codigo_sistema_siss2 := punto.codigo_sistema_siss; --1
				nombre_conduccion2 := punto.nombre_conduccion; --2
				id_tramo_conectado2 := punto.id_tramo_conectado; --3
				anio_instalacion2 := punto.anio_instalacion; --4
				lifecyclestatus2 := punto.lifecyclestatus; --5
				--tipo_tramo2 := punto.tipo_tramo; --6
				tipo_operacion2 := punto.tipo_operacion; --6
				diameter2 := punto.diameter; --7	
				material2 := punto.material; --8 
				otromaterial2 = punto.material; --9				
				presion_maxima_trabajo2 := punto.presion_maxima_trabajo; --10
				measuredlength2 := punto.measuredlength; --11
				profundidad_media_tramo2 := punto.profundidad_media_tramo; --12
				--slope2 := punto.slope;--14
				tipo_terreno2 := punto.tipo_terreno; --13
				porcentaje_napa2 := punto.porcentaje_napa; --14
				paralelo2 := punto.paralelo; --15
				ownedby2 := punto.ownedby;
				
				codigo_obra2 = punto.codigo_obra;
				assetid2 = punto.assetid;			
				gdb_archive_oid2 := punto.gdb_archive_oid;
				gdb_from_date2 := punto.gdb_from_date;
				proyecto_informado_siss2 := punto.proyecto_informado_siss;	
			END IF;			
			
			IF assetid = assetid2 THEN
				IF COALESCE(proyecto_informado_siss,'Unknown')  <> COALESCE(proyecto_informado_siss2,'Unknown')  AND correlativo = 2 THEN
					correlativo := correlativo + 1;
				
				ELSIF (COALESCE(proyecto_informado_siss2,'Unknown')  <> COALESCE(punto.proyecto_informado_siss,'Unknown')  AND correlativo = 3) OR assetid <> punto.assetid THEN
					correlativo := correlativo + 1;
				END IF;	
				IF correlativo = 4  AND gdb_from_date2 >= fecha_inicio AND gdb_from_date2 <= fecha_fin AND proyecto_informado_siss2 is not null AND codigo_obra2 is not null THEN		
					IF ownedby = 103 THEN rut = '76833300';
					ELSIF ownedby = 104 THEN rut = '96963440';
					ELSE rut = NULL;
					END IF;
					
					IF  COALESCE(id_tramo_conectado,'0')  <>  COALESCE(id_tramo_conectado2,'0') THEN
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss2, codigo_sistema_siss2, 1102, codigo_obra2, id_tramo_conectado2, 3, id_tramo_conectado::text, id_tramo_conectado2::text, gdb_from_date2, gdb_archive_oid2);
					END IF;						
					IF  COALESCE(anio_instalacion,'0')  <>  COALESCE(anio_instalacion2,'0') and material > 17 THEN
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss2, codigo_sistema_siss2, 1102, codigo_obra2, id_tramo_conectado2, 4, anio_instalacion::text, anio_instalacion2::text, gdb_from_date2, gdb_archive_oid2);
					END IF;					
					IF  COALESCE(lifecyclestatus,'0')  <>  COALESCE(lifecyclestatus2,'0') THEN
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss2, codigo_sistema_siss2, 1102, codigo_obra2, id_tramo_conectado2, 5, lifecyclestatus::text, lifecyclestatus2::text, gdb_from_date2, gdb_archive_oid2);
					END IF;
			
					IF  COALESCE(tipo_operacion,'0')  <>  COALESCE(tipo_operacion2,'0') THEN
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss2, codigo_sistema_siss2, 1102, codigo_obra2, id_tramo_conectado2, 6, tipo_operacion::text, tipo_operacion2::text, gdb_from_date2, gdb_archive_oid2);
					END IF;							
					IF  COALESCE(diameter,'0')  <>  COALESCE(diameter2,'0') THEN
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss2, codigo_sistema_siss2, 1102, codigo_obra2, id_tramo_conectado2,7, diameter::text, diameter2::text, gdb_from_date2, gdb_archive_oid2);
					END IF;	
					IF  COALESCE(material,'0')  <>  COALESCE(material2,'0') THEN
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss2, codigo_sistema_siss2, 1102, codigo_obra2, id_tramo_conectado2, 8, material::text, material2::text, gdb_from_date2, gdb_archive_oid2);	
					END IF;
					IF  COALESCE(otromaterial,'0')  <>  COALESCE(otromaterial2,'0') THEN
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss2, codigo_sistema_siss2, 1102, codigo_obra2, id_tramo_conectado2, 9, material::text, material2::text, gdb_from_date2, gdb_archive_oid2);
					END IF;	
					IF  COALESCE(presion_maxima_trabajo,'0')  <>  COALESCE(presion_maxima_trabajo2,'0') THEN
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss2, codigo_sistema_siss2, 1102, codigo_obra2, id_tramo_conectado2, 10, presion_maxima_trabajo::text, presion_maxima_trabajo2::text, gdb_from_date2, gdb_archive_oid2);
					END IF;	
					/*IF  COALESCE(measuredlength,'0')  <>  COALESCE(measuredlength2,'0') THEN
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss2, codigo_sistema_siss2, 1102, codigo_obra2, '0', 11, measuredlength::text, measuredlength2::text, gdb_from_date2, gdb_archive_oid2);
					END IF;	*/
					IF  COALESCE(profundidad_media_tramo,'0')  <>  COALESCE(profundidad_media_tramo2,'0') THEN
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss2, codigo_sistema_siss2, 1102, codigo_obra2, id_tramo_conectado2, 12, profundidad_media_tramo::text, profundidad_media_tramo2::text, gdb_from_date2, gdb_archive_oid2);
					END IF;	
					IF  COALESCE(tipo_terreno,'0')  <>  COALESCE(tipo_terreno2,'0') THEN
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss2, codigo_sistema_siss2, 1102, codigo_obra2, id_tramo_conectado2, 13,tipo_terreno::text, tipo_terreno2::text, gdb_from_date2, gdb_archive_oid2);
					END IF;						
					IF  COALESCE(porcentaje_napa,'0')  <>  COALESCE(porcentaje_napa2,'0') THEN
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss2, codigo_sistema_siss2, 1102, codigo_obra2, id_tramo_conectado2, 14, tipo_obra_mitigacion::text, tipo_obra_mitigacion2::text, gdb_from_date2, gdb_archive_oid2);
					END IF;
					IF  COALESCE(paralelo,'0')  <>  COALESCE(paralelo2,'0') THEN
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss2, codigo_sistema_siss2, 1102, codigo_obra2, id_tramo_conectado2, 15, telemetria::text, telemetria2::text, gdb_from_date2, gdb_archive_oid2);
					END IF;	
					
					codigo_sistema_siss := codigo_sistema_siss2; --1
					nombre_conduccion := nombre_conduccion2; --2
					id_tramo_conectado := id_tramo_conectado2; --3
					anio_instalacion := anio_instalacion2; --4
					lifecyclestatus := lifecyclestatus2; --5
					--tipo_tramo := tipo_tramo2; --6
					tipo_operacion := tipo_operacion2; --7
					diameter := diameter2; --8	
					material := material2; --9
					otromaterial = otromaterial2; --10	
					presion_maxima_trabajo := presion_maxima_trabajo2; --11
					measuredlength := measuredlength2; --12
					profundidad_media_tramo := profundidad_media_tramo2; --13
					--slope := slope2;--14
					tipo_terreno := tipo_terreno2; --15
					porcentaje_napa := porcentaje_napa2; --16
					paralelo := paralelo2; --17	
					codigo_obra = codigo_obra2;
					ownedby := ownedby2;	
					
					proyecto_informado_siss = proyecto_informado_siss2;	
										
				END IF;
				IF correlativo = 3 THEN
				
					codigo_sistema_siss2 := punto.codigo_sistema_siss; --1
					nombre_conduccion2 := punto.nombre_conduccion; --2
					id_tramo_conectado2 := punto.id_tramo_conectado; --3
					anio_instalacion2 := punto.anio_instalacion; --4
					lifecyclestatus2 := punto.lifecyclestatus; --5
					--tipo_tramo2 := punto.tipo_tramo; --6
					tipo_operacion2 := punto.tipo_operacion; --7
					diameter2 := punto.diameter; --8	
					material2 := punto.material; --9 
					otromaterial2 = punto.material; --10		
					presion_maxima_trabajo2 := punto.presion_maxima_trabajo; --11
					measuredlength2 := punto.measuredlength; --12
					profundidad_media_tramo2 := punto.profundidad_media_tramo; --13
					--slope2 := punto.slope;--14
					tipo_terreno2 := punto.tipo_terreno; --15
					porcentaje_napa2 := punto.porcentaje_napa; --16
					paralelo2 := punto.paralelo; --17
					ownedby2 := punto.ownedby;
					
					codigo_obra2 = punto.codigo_obra;
					assetid2 = punto.assetid;			
					gdb_archive_oid2 := punto.gdb_archive_oid;
					gdb_from_date2 := punto.gdb_from_date;
					proyecto_informado_siss2 := punto.proyecto_informado_siss;							
				END IF;	
			END IF;
			IF correlativo = 2 THEN			
				codigo_sistema_siss := codigo_sistema_siss2; --1
				nombre_conduccion := nombre_conduccion2; --2
				id_tramo_conectado := id_tramo_conectado2; --3
				anio_instalacion := anio_instalacion2; --4
				lifecyclestatus := lifecyclestatus2; --5
				--tipo_tramo := tipo_tramo2; --6
				tipo_operacion := tipo_operacion2; --7
				diameter := diameter2; --8	
				material := material2; --9 --10
				otromaterial = otromaterial2; --10
				presion_maxima_trabajo := presion_maxima_trabajo2; --11
				measuredlength := measuredlength2; --12
				profundidad_media_tramo := profundidad_media_tramo2; --13
				--slope := slope2;--14
				tipo_terreno := tipo_terreno2; --15
				porcentaje_napa := porcentaje_napa2; --16
				paralelo := paralelo2; --17	
				ownedby := ownedby2;
				
				codigo_obra = codigo_obra2;
				proyecto_informado_siss = proyecto_informado_siss2;	
			END IF;				

			IF assetid <> punto.assetid THEN
				correlativo := 2;
				
				codigo_sistema_siss := punto.codigo_sistema_siss; --1
				nombre_conduccion := punto.nombre_conduccion; --2
				id_tramo_conectado := punto.id_tramo_conectado; --3
				anio_instalacion := punto.anio_instalacion; --4
				lifecyclestatus := punto.lifecyclestatus; --5
				--tipo_tramo := punto.tipo_tramo; --6
				tipo_operacion := punto.tipo_operacion; --7
				diameter := punto.diameter; --8	
				material := punto.material; --9
				otromaterial = punto.material; --10			
				presion_maxima_trabajo := punto.presion_maxima_trabajo; --11
				measuredlength := punto.measuredlength; --12
				profundidad_media_tramo := punto.profundidad_media_tramo; --13
				--slope := punto.slope;--14
				tipo_terreno := punto.tipo_terreno; --15
				porcentaje_napa := punto.porcentaje_napa; --16
				paralelo := punto.paralelo; --17
				ownedby := punto.ownedby;
				
				codigo_obra = punto.codigo_obra;
				assetid = punto.assetid;
				gdb_archive_oid = punto.gdb_archive_oid;			
				gdb_from_date := punto.gdb_from_date;
				proyecto_informado_siss := punto.proyecto_informado_siss;		
			END IF;
			IF  cuenta2 = cantidad AND punto.gdb_from_date >= fecha_inicio AND punto.gdb_from_date <= fecha_fin AND punto.proyecto_informado_siss is not null  THEN
				IF ownedby = 103 THEN rut = '76833300';
				ELSIF ownedby = 104 THEN rut = '96963440';
				ELSE rut = NULL;
				END IF;			
				
				IF  COALESCE(id_tramo_conectado,'0')  <>  COALESCE(punto.id_tramo_conectado,'0') THEN
					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, punto.proyecto_informado_siss, punto.codigo_sistema_siss, 1102, punto.codigo_obra, punto.id_tramo_conectado, 3, id_tramo_conectado::text, punto.id_tramo_conectado::text, punto.gdb_from_date, punto.gdb_archive_oid);
				END IF;					
				IF  COALESCE(anio_instalacion,'0')  <>  COALESCE(punto.anio_instalacion,'0') THEN
					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, punto.proyecto_informado_siss, punto.codigo_sistema_siss, 1102, punto.codigo_obra, punto.id_tramo_conectado, 4, anio_instalacion::text, anio_instalacion::text, punto.gdb_from_date, punto.gdb_archive_oid);
				END IF;					
				IF  COALESCE(lifecyclestatus,'0')  <>  COALESCE(punto.lifecyclestatus,'0') THEN
					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, punto.proyecto_informado_siss, punto.codigo_sistema_siss, 1102, punto.codigo_obra, punto.id_tramo_conectado, 5, lifecyclestatus::text, punto.lifecyclestatus::text, punto.gdb_from_date, punto.gdb_archive_oid);
				END IF;								
				IF  COALESCE(tipo_operacion,'0')  <>  COALESCE(punto.tipo_operacion,'0') THEN
					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, punto.proyecto_informado_siss2, punto.codigo_sistema_siss, 1102, punto.codigo_obra, punto.id_tramo_conectado, 6, tipo_operacion::text, punto.tipo_operacion::text, punto.gdb_from_date, punto.gdb_archive_oid);
				END IF;							
				IF  COALESCE(diameter,'0')  <>  COALESCE(punto.diameter,'0') THEN
					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, punto.proyecto_informado_siss, punto.codigo_sistema_siss, 1102, punto.codigo_obra, punto.id_tramo_conectado, 7, diameter::text, round(punto.diameter,0)::text, punto.gdb_from_date, punto.gdb_archive_oid);
				END IF;	
				IF  COALESCE(material,'0')  <>  COALESCE(punto.material,'0') THEN
					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, punto.proyecto_informado_siss, punto.codigo_sistema_siss, 1102, punto.codigo_obra, punto.id_tramo_conectado, 8, material::text, punto.material::text, punto.gdb_from_date, punto.gdb_archive_oid);
				END IF;
				IF  COALESCE(otromaterial,'0')  <>  COALESCE(punto.otromaterial,'0') THEN
					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, punto.proyecto_informado_siss, punto.codigo_sistema_siss, 1102, punto.codigo_obra, punto.id_tramo_conectado, 9, material::text, punto.material::text, punto.gdb_from_date, punto.gdb_archive_oid);
				END IF;	
				IF  COALESCE(presion_maxima_trabajo,'0')  <>  COALESCE(punto.presion_maxima_trabajo,'0') THEN
					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, punto.proyecto_informado_siss, punto.codigo_sistema_siss, 1102, punto.codigo_obra, punto.id_tramo_conectado, 10, presion_maxima_trabajo::text, punto.presion_maxima_trabajo::text, punto.gdb_from_date, punto.gdb_archive_oid);
				END IF;	
				/*IF  COALESCE(measuredlength,'0')  <>  COALESCE(punto.measuredlength,'0') THEN
					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, punto.proyecto_informado_siss, punto.codigo_sistema_siss, 1102, punto.codigo_obra, '0', 11, measuredlength::text, punto.measuredlength::text, punto.gdb_from_date, punto.gdb_archive_oid);
				END IF;	*/
				IF  COALESCE(profundidad_media_tramo,'0')  <>  COALESCE(punto.profundidad_media_tramo,'0') THEN
					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, punto.proyecto_informado_siss, punto.codigo_sistema_siss, 1102, punto.codigo_obra, punto.id_tramo_conectado, 12, profundidad_media_tramo::text, punto.profundidad_media_tramo::text, punto.gdb_from_date, punto.gdb_archive_oid);
				END IF;	
				IF  COALESCE(tipo_terreno,'0')  <>  COALESCE(punto.tipo_terreno,'0') THEN
					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, punto.proyecto_informado_siss, punto.codigo_sistema_siss, 1102, punto.codigo_obra, punto.id_tramo_conectado, 13, tipo_terreno::text, punto.tipo_terreno::text, punto.gdb_from_date, punto.gdb_archive_oid);
				END IF;						
				IF  COALESCE(porcentaje_napa,'0')  <>  COALESCE(punto.porcentaje_napa,'0') THEN
					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, punto.proyecto_informado_siss, punto.codigo_sistema_siss, 1102, punto.codigo_obra, punto.id_tramo_conectado, 14, porcentaje_napa::text, punto.porcentaje_napa::text, punto.gdb_from_date, punto.gdb_archive_oid);
				END IF;		
				IF  COALESCE(paralelo,'0')  <>  COALESCE(punto.paralelo,'0') THEN
					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, punto.proyecto_informado_siss, punto.codigo_sistema_siss, 1102, punto.codigo_obra, punto.id_tramo_conectado, 15, paralelo::text, punto.paralelo::text, punto.gdb_from_date, punto.gdb_archive_oid);
				END IF;	
			END IF;
		END IF;
	END LOOP;
END IF;			

 resultado := cantidad::text;
 RETURN resultado;
END;
$BODY$;

ALTER FUNCTION owd.insert_1705_1102(date, date)
    OWNER TO owd;
