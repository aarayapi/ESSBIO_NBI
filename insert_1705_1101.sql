-- FUNCTION: owd.insert_1705_1101(timestamp without time zone, timestamp without time zone)

-- DROP FUNCTION IF EXISTS owd.insert_1705_1101(timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION owd.insert_1705_1101(
	fecha_inicio timestamp without time zone,
	fecha_fin timestamp without time zone)
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE 
	--punto owd.vmt_sewerline_sb%ROWTYPE;	
	punto record;
	punto2 record;	

	codigoproceso smallint;
	codigoarchivo smallint;
	rut character varying(20);
    periodo integer;

    codigo_sistema_siss integer;
    codigo_obra character varying(255);	
	
    etapa integer;	
    name character varying(255);
	tipo_obra_origen integer;
	codigo_obra_origen  character varying(255);
	tipo_obra_destino integer;
	codigo_obra_destino character varying(255);
	--longitud_tramo numeric(38,2);
	ownedby smallint;
	
	assetid character varying(100);
	
    codigo_sistema_siss2 integer;
    codigo_obra2 character varying(255);
	
	
    etapa2 integer;	
    name2 character varying(255);
	tipo_obra_origen2 integer;
	codigo_obra_origen2  character varying(255);
	tipo_obra_destino2 integer;
	codigo_obra_destino2 character varying(255);
	--longitud_tramo2 numeric(38,2);
	--longitud_total2 numeric(38,2);
	ownedby2 smallint;	
	
	assetid2 character varying(100);
	
  	gdb_from_date timestamp;
	gdb_from_date2 timestamp;
	longitud_total numeric(38,2);
	gdb_archive_oid integer;
	gdb_archive_oid2 integer;
	proyecto_informado_siss character varying(100);
	proyecto_informado_siss2 character varying(100);
	resultado text;
	cantidad integer;
	correlativo integer;
	cuenta2 integer;
BEGIN
codigoproceso :=  5;
codigoarchivo := 1705; 
--rut := '96963440';
periodo := ((date_part('year'::text, CURRENT_DATE) - 1::double precision) || '12')::integer;

resultado   := '';
correlativo := 0;
cantidad := 0;
cuenta2 := 0;
longitud_total := 0;

SELECT count(sl.gdb_archive_oid) into cantidad from owd.vmt_1705_1101_waterline_dbl sl WHERE --sl.proyecto_informado_siss is not null AND 
	 sl.assetgroup = 1 OR sl.assettype = 1
	AND sl.gdb_from_date <= fecha_fin ;
 
if cantidad > 0 then
--raise notice 'cuenta';
	FOR punto IN SELECT sl.proyecto_informado_siss,  sl.codigo_obra , sl.id_tramo_conectado,  sl.creationdate, 
sl.ownedby, sl.measuredlength, sl.objectid, sl.gdb_from_date,  sl.gdb_archive_oid, sl.lifecyclestatus, sl.codigo_sistema_siss
	from owd.vmt_1705_1101_waterline_dbl sl WHERE 
	 sl.assetgroup = 1 OR sl.assettype = 1
	AND sl.gdb_from_date <= fecha_fin 
	ORDER BY sl.ownedby, sl.codigo_obra, sl.gdb_from_date ASC	
	LOOP
		correlativo := correlativo + 1;
		

		
		IF correlativo = 1 THEN
			codigo_obra := punto.codigo_obra;
			proyecto_informado_siss := punto.proyecto_informado_siss;
			codigo_sistema_siss := punto.codigo_sistema_siss;
			ownedby := punto.ownedby;
			--longitud_total = punto.measuredlength;	
			
			IF punto.gdb_from_date < fecha_inicio  THEN
				IF punto.measuredlength is not null THEN
					longitud_total := longitud_total + punto.measuredlength;	
				END IF;
			ELSIF punto.measuredlength is not NULL AND longitud_total > 0  THEN
			--raise notice 'cuenta';
				IF ownedby = 103 THEN rut := '76833300';
				ELSIF ownedby = 104 THEN rut := '96963440';
				ELSE rut := NULL;
				END IF;			
				
				INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
				VALUES (codigoproceso, codigoarchivo, rut, periodo, punto.proyecto_informado_siss, punto.codigo_sistema_siss, 1101, punto.codigo_obra, punto.id_tramo_conectado, 9, round(longitud_total,2)::text, round(longitud_total + punto.measuredlength,2)::text, punto.gdb_from_date, punto.objectid::integer);
				longitud_total := longitud_total + punto.measuredlength;
			END IF;		
			
		ELSIF correlativo >= 2 THEN			
			codigo_obra2 := punto.codigo_obra;	
			ownedby2 := punto.ownedby;
			IF codigo_obra = codigo_obra2  THEN
				IF punto.gdb_from_date < fecha_inicio THEN
					IF punto.measuredlength is not null THEN
						longitud_total := longitud_total + punto.measuredlength;	
					END IF;
				ELSIF punto.measuredlength is not null AND longitud_total > 0 THEN
					--raise notice 'cuenta';
					IF ownedby2 = 103 THEN rut := '76833300';
					ELSIF ownedby2 = 104 THEN rut := '96963440';
					ELSE rut := NULL;
					END IF;		

					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, punto.proyecto_informado_siss, punto.codigo_sistema_siss, 1101, punto.codigo_obra, punto.id_tramo_conectado, 9, round(longitud_total,2)::text, round(longitud_total + punto.measuredlength, 2)::text, punto.gdb_from_date, punto.objectid::integer);
					longitud_total := longitud_total + punto.measuredlength;
				END IF;
			ELSE
				codigo_obra := punto.codigo_obra;
				proyecto_informado_siss := punto.proyecto_informado_siss;
				codigo_sistema_siss := punto.codigo_sistema_siss;	
				ownedby := punto.ownedby;
				correlativo := 1;
				
				IF punto.gdb_from_date < fecha_inicio  THEN
					IF punto.measuredlength is not null THEN
						longitud_total := punto.measuredlength;	
					END IF;
				ELSE
				
					longitud_total := 0;
					
					/*IF punto.measuredlength is not null THEN
				
						IF ownedby = 103 THEN rut = '76833300';
						ELSIF ownedby = 104 THEN rut = '96963440';
						ELSE rut = NULL;
						END IF;					
					--raise notice 'cuenta';
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, punto.proyecto_informado_siss, punto.codigo_sistema_siss, 1101, punto.codigo_obra, punto.id_tramo_conectado, 9, '0'::text, round(punto.measuredlength,2 )::text, punto.gdb_from_date, punto.objectid::integer);
						longitud_total := punto.measuredlength;
					END IF;*/
					
				END IF;						
				
			END IF;
		END IF;		
	END LOOP;
END IF;

resultado   := '';
correlativo := 1;
cantidad := 0;
cuenta2 := 0;

SELECT COUNT(*) into cantidad FROM owd.vmt_1705_1101_waterline_dbl_2 vmt WHERE 
	(vmt.assetgroup = 1 OR (vmt.assettype = 2 OR vmt.assettype = 41 OR vmt.assettype = 42))
	AND vmt.gdb_from_date >= fecha_inicio AND vmt.gdb_from_date <= fecha_fin;
	
if cantidad > 0 then	
	FOR punto2 IN SELECT * 
	FROM owd.vmt_1705_1101_waterline_dbl_2 vmt WHERE 
		(vmt.assetgroup = 1 OR (vmt.assettype = 2 OR vmt.assettype = 41 OR vmt.assettype = 42))
		AND vmt.gdb_from_date >= fecha_inicio AND vmt.gdb_from_date <= fecha_fin
		order by vmt.codigo_obra

		LOOP

		cuenta2 := cuenta2 + 1;	

		IF correlativo = 1 THEN
			correlativo := correlativo + 1;
			codigo_sistema_siss := punto2.codigo_sistema_siss;
			codigo_obra := punto2.codigo_obra;
			etapa := punto2.etapa;
			name := punto2.nombre_conduccion;
			tipo_obra_origen:= punto2.tipo_obra_origen;
			codigo_obra_origen := punto2.codigo_obra_origen;
			tipo_obra_destino:= punto2.tipo_obra_destino;
			codigo_obra_destino	:=	punto2.codigo_obra_destino;	
			ownedby 	:=	punto2.ownedby;

			gdb_archive_oid := punto2.gdb_archive_oid;
			gdb_from_date := punto2.gdb_from_date;
			proyecto_informado_siss := punto2.proyecto_informado_siss;
			assetid := punto2.assetid;
			gdb_from_date = punto2.gdb_from_date;

		ELSIF correlativo > 1 THEN 
			--correlativo := correlativo + 1;
			IF correlativo = 2 THEN
				codigo_sistema_siss2 := punto2.codigo_sistema_siss;
				codigo_obra2 := punto2.codigo_obra;
				etapa2 := punto2.etapa;
				name2 := punto2.nombre_conduccion;
				tipo_obra_origen2:= punto2.tipo_obra_origen;
				codigo_obra_origen2 := punto2.codigo_obra_origen;
				tipo_obra_destino2 := punto2.tipo_obra_destino;
				codigo_obra_destino2 :=	punto2.codigo_obra_destino;				
				ownedby2 :=	punto2.ownedby;

				gdb_archive_oid2 := punto2.gdb_archive_oid;
				gdb_from_date2 := punto2.gdb_from_date;
				proyecto_informado_siss2 := punto2.proyecto_informado_siss;
				assetid2 := punto2.assetid;	
				gdb_from_date2 = punto2.gdb_from_date;
			END IF;
			IF assetid = assetid2 THEN
				IF proyecto_informado_siss <> proyecto_informado_siss2 AND correlativo = 2 THEN
					correlativo := correlativo + 1;

				ELSIF (proyecto_informado_siss2 <> punto2.proyecto_informado_siss AND correlativo = 3) OR assetid <> punto2.assetid THEN
					correlativo := correlativo + 1;
				END IF;			
				IF correlativo = 4  AND gdb_from_date2 >= fecha_inicio AND gdb_from_date2 <= fecha_fin  AND proyecto_informado_siss2 is not null THEN
					IF ownedby = 103 THEN rut = '76833300';
					ELSIF ownedby = 104 THEN rut = '96963440';
					ELSE rut = NULL;
					END IF;
					IF etapa <> etapa2 THEN
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss2, codigo_sistema_siss2, 1101, codigo_obra2,  punto2.id_tramo_conectado, 3, etapa::text, etapa2::text, gdb_from_date2, gdb_archive_oid2);
					END IF;	
					IF name <> name2 THEN
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss2, codigo_sistema_siss2, 1101, codigo_obra2, punto2.id_tramo_conectado, 4, name::text, name2::text, gdb_from_date2, gdb_archive_oid2);
					END IF;	
					IF tipo_obra_origen <> tipo_obra_origen2 THEN
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss, codigo_sistema_siss2, 1101, codigo_obra2, punto2.id_tramo_conectado, 5, tipo_obra_origen::text, tipo_obra_origen2::text, gdb_from_date2, gdb_archive_oid2);
					END IF;	
					IF codigo_obra_origen <> codigo_obra_origen2 THEN
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss, codigo_sistema_siss2, 1101, codigo_obra2, punto2.id_tramo_conectado, 6, codigo_obra_origen::text, codigo_obra_origen2::text, gdb_from_date2, gdb_archive_oid2);
					END IF;						
					IF tipo_obra_destino <> tipo_obra_destino2 THEN
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss, codigo_sistema_siss2, 1101, codigo_obra2, punto2.id_tramo_conectado, 7, tipo_obra_destino::text, tipo_obra_destino2::text, gdb_from_date2, gdb_archive_oid2);
					END IF;	
					IF codigo_obra_destino <> codigo_obra_destino2 THEN
						INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
						VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss, codigo_sistema_siss2, 1101, codigo_obra2, punto2.id_tramo_conectado, 8, codigo_obra_destino::text, codigo_obra_destino2::text, gdb_from_date2, gdb_archive_oid2);
					END IF;					
					correlativo := 3;
					codigo_sistema_siss := codigo_sistema_siss2;
					codigo_obra := codigo_obra2;
					etapa := etapa2;
					name := name2;
					tipo_obra_origen:= tipo_obra_origen2;
					codigo_obra_origen := codigo_obra_origen2;
					tipo_obra_destino:= tipo_obra_destino2;
					codigo_obra_destino	:=	codigo_obra_destino2;	
					ownedby :=	ownedby2;

					gdb_archive_oid := gdb_archive_oid2;
					gdb_from_date := gdb_from_date2;
					proyecto_informado_siss := proyecto_informado_siss2;
					assetid := assetid2;
					gdb_from_date = gdb_from_date2;				

				END IF;
				IF correlativo = 3 THEN
					codigo_sistema_siss2 := punto2.codigo_sistema_siss;
					codigo_obra2 := punto2.codigo_obra;
					etapa2 := punto2.etapa;
					name2 :=punto2.nombre_conduccion;
					tipo_obra_origen2:= punto2.tipo_obra_origen;
					codigo_obra_origen2 := punto2.codigo_obra_origen;
					tipo_obra_destino2:= punto2.tipo_obra_destino;
					codigo_obra_destino2	:=	punto2.codigo_obra_destino;	
					ownedby2 :=	punto2.ownedby;

					gdb_archive_oid2 := punto2.gdb_archive_oid;
					gdb_from_date2 := punto2.gdb_from_date;
					proyecto_informado_siss2 := punto2.proyecto_informado_siss;
					assetid2 := punto2.assetid;
					gdb_from_date2 = punto2.gdb_from_date;		
				END IF;
			END IF;
			IF correlativo = 2 THEN	
				codigo_sistema_siss := codigo_sistema_siss2;
				codigo_obra := codigo_obra2;
				etapa := etapa2;
				name := name2;
				tipo_obra_origen:= tipo_obra_origen2;
				codigo_obra_origen := codigo_obra_origen2;
				tipo_obra_destino:= tipo_obra_destino2;
				codigo_obra_destino	:=	codigo_obra_destino2;	
				ownedby :=	ownedby2;

				gdb_archive_oid := gdb_archive_oid2;
				gdb_from_date := gdb_from_date2;
				proyecto_informado_siss := proyecto_informado_siss2;
				assetid := assetid2;
				gdb_from_date = gdb_from_date2;		

			END IF;	
			IF assetid <> punto2.assetid THEN	
				correlativo := 2;
				codigo_sistema_siss := punto2.codigo_sistema_siss;
				codigo_obra := punto2.codigo_obra;
				etapa := punto2.etapa;
				name := punto2.nombre_conduccion;
				tipo_obra_origen:= punto2.tipo_obra_origen;
				codigo_obra_origen := punto2.codigo_obra_origen;
				tipo_obra_destino:= punto2.tipo_obra_destino;
				codigo_obra_destino	:=	punto2.codigo_obra_destino;	
				ownedby :=	punto2.ownedby;

				gdb_archive_oid := punto2.gdb_archive_oid;
				gdb_from_date := punto2.gdb_from_date;
				proyecto_informado_siss := punto2.proyecto_informado_siss;
				assetid := punto2.assetid;
				gdb_from_date = punto2.gdb_from_date;
			END IF;
		END IF;
			IF  cuenta2 = cantidad AND punto2.gdb_from_date >= fecha_inicio AND punto2.gdb_from_date <= fecha_fin  AND punto2.proyecto_informado_siss is not null THEN
				IF ownedby = 103 THEN rut = '76833300';
				ELSIF ownedby = 104 THEN rut = '96963440';
				ELSE rut = NULL;
				END IF;	
				IF etapa <> punto2.etapa THEN
					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss2, codigo_sistema_siss2, 1101, codigo_obra2,  punto2.id_tramo_conectado, 3, etapa::text, punto2.etapa::text, gdb_from_date2, gdb_archive_oid2);
				END IF;	
				IF name <> punto2.nombre_conduccion THEN
					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss2, codigo_sistema_siss2, 1101, codigo_obra2, punto2.id_tramo_conectado, 4, name::text, punto2.nombre_conduccion::text, gdb_from_date2, gdb_archive_oid2);
				END IF;	
				IF tipo_obra_origen <> punto2.tipo_obra_origen THEN
					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss, codigo_sistema_siss2, 1101, codigo_obra2, punto2.id_tramo_conectado, 5, tipo_obra_origen::text, punto2.tipo_obra_origen::text, gdb_from_date2, gdb_archive_oid2);
				END IF;	
				IF codigo_obra_origen <> punto2.codigo_obra_origen THEN
					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss, codigo_sistema_siss2, 1101, codigo_obra2, punto2.id_tramo_conectado, 6, codigo_obra_origen::text, punto2.codigo_obra_origen::text, gdb_from_date2, gdb_archive_oid2);
				END IF;						
				IF tipo_obra_destino <> punto2.tipo_obra_destino THEN
					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss, codigo_sistema_siss2, 1101, codigo_obra2, punto2.id_tramo_conectado, 7, tipo_obra_destino::text, punto2.tipo_obra_destino::text, gdb_from_date2, gdb_archive_oid2);
				END IF;	
				IF codigo_obra_destino <> punto2.codigo_obra_destino THEN
					INSERT INTO owd.tabla_1705("codigoProceso", "codigoArchivo", rut, periodo, "codigoProyecto", "codigoSistema", "codigoObraTipo", "codigoObra", "codigoTramo", "codigoAtributo", "ValorAnterior", "ValorNuevo", fecha, gdb_archive_id)	
					VALUES (codigoproceso, codigoarchivo, rut, periodo, proyecto_informado_siss, codigo_sistema_siss2, 1101, codigo_obra2, punto2.id_tramo_conectado, 8, codigo_obra_destino::text, punto2.codigo_obra_destino::text, gdb_from_date2, gdb_archive_oid2);
				END IF;	
		END IF;
	END LOOP;
END IF;	

 resultado := cantidad::text;
 RETURN resultado;
END;
$BODY$;

ALTER FUNCTION owd.insert_1705_1101(timestamp without time zone, timestamp without time zone)
    OWNER TO owd;
