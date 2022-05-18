-- drop FUNCTION usr_jesoto.med_estamento
CREATE FUNCTION usr_jesoto.med_estamento(varchar) returns text 
as 
$$
	select  distinct replace (med_estamento_desc,'PSICOLOGÍA','PSICOLOGO/A') as estamento
			from admomi.iddmed
	where medico  =$1	
	
$$ 
language sql; 

select usr_jesoto.med_estamento(text);



-- drop FUNCTION usr_jesoto.id_estamento
CREATE FUNCTION usr_jesoto.id_estamento(int) returns text 
as 
$$
	select  distinct replace (med_estamento_desc,'PSICOLOGÍA','PSICOLOGO/A') as estamento
		from admomi.iddmed
	where id  =$1	
	
$$ 
language sql; 


-- drop FUNCTION usr_jesoto.id_med_nombre
CREATE FUNCTION usr_jesoto.id_med_nombre(int) returns text 
as 
$$
	select  distinct med_nombre as nom_profesional
		from admomi.iddmed
	where id  =$1	
	
$$ 
language sql; 




-- drop FUNCTION usr_jesoto.id_med_especialidad
CREATE FUNCTION usr_jesoto.id_med_especialidad(int) returns text 
as 
$$ 
	select  distinct med_especialidad_desc	from admomi.iddmed	where id  =$1	
	
$$ 
language sql; 

select usr_jesoto.id_med_especialidad(int);

select usr_jesoto.med_estamento(text)||' - '||usr_jesoto.id_estamento(int) estamento;


CREATE OR REPLACE FUNCTION usr_jesoto.percapita_al_dia(integer)
 RETURNS date
 LANGUAGE sql
AS $function$ 

 select distinct fecha_corte2 
 	from usr_jesoto.reporte_percapita 
 	where fecha_corte2 in (select max(fecha_corte2 ) from usr_jesoto.reporte_percapita)
 		and aceptado_rechazado ='ACEPTADO'
 		and run=$1	
 
 $function$
;



-- drop FUNCTION usr_jesoto.percapita_fecha
CREATE FUNCTION usr_jesoto.percapita_fecha(int) returns date 
as 
$$ 

drop table if exists percapita;
create temp table percapita as 
 select distinct run ,fecha_corte2 
 	from usr_jesoto.reporte_percapita 
 	where fecha_corte2 in (select max(fecha_corte2 ) from usr_jesoto.reporte_percapita)
 		and aceptado_rechazado ='ACEPTADO'
 ;
create index percapita_i_01 on percapita (run) tablespace tb_index;
create index percapita_i_02 on percapita (fecha_corte2) tablespace tb_index;
 		
select distinct fecha_corte2 from percapita where run=$1	
 
 $$ 
language sql;

select usr_jesoto.percapita_al_dia(15339339);
select usr_jesoto.percapita_fecha(15339339);


select distinct 
	 a.nif2 
	 ,a.run
	, a.pac_nombre_completo as nombre_completo
	, usr_jesoto.genero(a.sexo) as genero
	, a.nacimiento
	, edad_en_agnios(now()::date,a.nacimiento) as edad
	, age (now()::date,a.nacimiento) as edad_actual
	, a.domicilio||' '||a.tiscab AS domicilio
	, a.centro 
	, a.telpart as telefono_1
	, a.teldesp as telefono_2
	, a.estado2 as dato_administrativo
	, (select b.fecha_corte2 from usr_jesoto.reporte_percapita as b where a.run=b.run and aceptado_rechazado ='ACEPTADO' and b.fecha_corte2 in (select max(fecha_corte2 ) from usr_jesoto.reporte_percapita)order by b.fecha_corte2 desc limit 1)
from admomi.iddpacpa3 as a
where edad_en_agnios(now()::date,a.nacimiento)= 15 -- between 15 and 19
--where a.nacimiento between '20021231' and '20070101' --7366
	and estado2 in ('ACTIVO','INACTIVO')
	and a.centro ='SAH'
order by 5
;



-- paginas de ayuda 
/*
https://w3resource.com/PostgreSQL/substring-function.php
https://www.postgresqltutorial.com/postgresql-string-functions/postgresql-substring/
*/
-- 
select *
from protocolos_omi_vigentes.pr__atencion_enfermedad_cronica_wp_000398
/*where (
		consejeria_actividad_fisica_wn_0310_t_v =1
	or 	consejeria_tabaquismo_wn_0313_t_v = 1
	or 	consejeria_alimentacion_saludable_wn_0311_t_v =1
	or  consejeria_salud_sexual_reproductiva_wn_0314_t_v =1
	or 	consejeria_consumo_drogas_wn_0312_t_v =1
	or 	consejeria_otras_areas_wn_0317_t_v =1 
	or 	consejeria_regulacion_fertilidad_wn_0315_t_v =1
	or 	consejeria_prevencion_vih_trans_sexual_wn_0316_t_v =1
	)
	*/
where columns like 'consejeria_'
;



select table_schema 
		,table_name
		,column_name
--		,substring(column_name similar '%#"tabaquismo#"%' escape '#')   as consejeria_tab
		, regexp_match(column_name ,'%#"tabaquismo#"%') as resultado
		, regexp_match(column_name ,'#"tabaquismo#"%') as resultado2
		, regexp_match('consejeria_tabaquismo_wn_0115_t_v'  ,'%#"tabaquismo#"%') as resultado3
		, regexp_match('consejeria_tabaquismo_wn_0115_t_v'  ,'%"tabaquismo#"%') as resultado4
from information_schema.columns 
where table_schema= 'protocolos_omi_vigentes'
and column_name like 'conse%' and column_name similar to '%tabaquismo%'
and data_type='numeric'
--and regexp_match(column_name ,'%#"tabaquismo#"%') ='tabaquismo'
order by 3
;

select --table_schema 
	--	,table_name
	--	,column_name
	--	,table_schema||'.'||table_name as protocolo
		'select distinct nif,fecha,medico_id , '||' '||column_name||' from '||table_schema||'.'||table_name||' where '||column_name||' = 1 union' as consulta_sql
from information_schema.columns 
where table_schema= 'protocolos_omi_vigentes'
and column_name like 'consejeria_%'and column_name similar to '%tabaquismo%'
and data_type='numeric'
--order by 3
;

select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0050_t_v from protocolos_omi_vigentes.pr_telesalud_wp_000411 where consejeria_actividad_fisica_wn_0050_t_v = 1 union
select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0051_t_v from protocolos_omi_vigentes.pr_kine_respiratorio_wp_000373 where consejeria_actividad_fisica_wn_0051_t_v = 1 union
select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0072_t_v from protocolos_omi_vigentes.pr_consulta_nutricional_adultos_wp_000133 where consejeria_actividad_fisica_wn_0072_t_v = 1 union
select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0102_t_v from protocolos_omi_vigentes.pr_protocolo_nutricionista_wp_000324 where consejeria_actividad_fisica_wn_0102_t_v = 1 union
select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0102_t_v from protocolos_omi_vigentes.pr_protocolo_rem_wp_000298 where consejeria_actividad_fisica_wn_0102_t_v = 1 union
select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0106_t_v from protocolos_omi_vigentes.pr_consulta_nutricional_ninos_wp_000315 where consejeria_actividad_fisica_wn_0106_t_v = 1 union
select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0185_t_v from protocolos_omi_vigentes.pr_visita_domiciliaria_wp_000362 where consejeria_actividad_fisica_wn_0185_t_v = 1 union
select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0217_t_v from protocolos_omi_vigentes.pr_cirugia_menor_wp_000343 where consejeria_actividad_fisica_wn_0217_t_v = 1 union
select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0288_t_v from protocolos_omi_vigentes.pr_nino_nino_sano_5_9_anos_wp_000336 where consejeria_actividad_fisica_wn_0288_t_v = 1 union
select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0310_t_v from protocolos_omi_vigentes.pr__atencion_enfermedad_cronica_wp_000398 where consejeria_actividad_fisica_wn_0310_t_v = 1 union
select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0311_t_v from protocolos_omi_vigentes.pr_rem_odontologico_wp_000318 where consejeria_actividad_fisica_wn_0311_t_v = 1 union
select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0354_t_v from protocolos_omi_vigentes.pr_control_integral_adolescente_clap_wp_000384 where consejeria_actividad_fisica_wn_0354_t_v = 1 union
select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0365_t_v from protocolos_omi_vigentes.pr_rehabilitacion_fisica_wp_000349 where consejeria_actividad_fisica_wn_0365_t_v = 1 union
select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0465_t_v from protocolos_omi_vigentes.pr_control_integral_adole_clap_b2031117_wp_000225 where consejeria_actividad_fisica_wn_0465_t_v = 1 union
select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0495_t_v from protocolos_omi_vigentes.pr_adulto_mayor_control_wp_000366 where consejeria_actividad_fisica_wn_0495_t_v = 1 union
select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0495_t_v from protocolos_omi_vigentes.pr_adulto_mayor_ingreso_wp_000367 where consejeria_actividad_fisica_wn_0495_t_v = 1 union
select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0495_t_v from protocolos_omi_vigentes.pr_adulto_mayor_ingreso_baja20170630_wp_000354 where consejeria_actividad_fisica_wn_0495_t_v = 1 union
select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0495_t_v from protocolos_omi_vigentes.pr_adulto_mayor_consulta_baja20170602_wp_000274 where consejeria_actividad_fisica_wn_0495_t_v = 1 union
select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0495_t_v from protocolos_omi_vigentes.pr_adulto_mayor_control_baja20170630_wp_000363 where consejeria_actividad_fisica_wn_0495_t_v = 1 union
select distinct nif,fecha,medico_id ,  consejeria_actividad_fisica_wn_0588_t_v from protocolos_omi_vigentes.pr_nino_nino_sano_023_meses_wp_000352 where consejeria_actividad_fisica_wn_0588_t_v = 1 
;



-- drop FUNCTION usr_jesoto.consulta_sql
CREATE FUNCTION usr_jesoto.consulta_sql(varchar) returns text 
as 
 $$
select 'select distinct nif,fecha,medico_id , '||' '||column_name||' from '||table_schema||'.'||table_name||' where '||column_name||' = 1 union' as consulta_sql
from information_schema.columns 
where table_schema= 'protocolos_omi_vigentes'
and column_name like 'consejeria_%'and column_name similar to '%'$1 '%' --'%tabaquismo%'
and data_type='numeric'
$$ 
language sql;

select usr_jesoto.consulta_sql('%tabaquismo%') 

-- drop FUNCTION usr_jesoto.consulta_sql
CREATE FUNCTION usr_jesoto.consulta_sql(varchar) returns text 
as 
 $$
select 'select distinct nif,fecha,medico_id , '||' '||column_name||' from '||table_schema||'.'||table_name||' where '||column_name||' = 1 union' as consulta_sql
from information_schema.columns 
where table_schema= 'protocolos_omi_vigentes'
and column_name like 'consejeria_%'and column_name similar to '%'$1 '%' --'%tabaquismo%'
and data_type='numeric'
$$ 
language sql;

select usr_jesoto.consulta_sql('%tabaquismo%') 



CREATE or replace FUNCTION usr_jesoto.consulta_sql(tb varchar ,campo varchar  ,filtro varchar) 
returns 
	table (tabla varchar  ,
			sql_consulta varchar ,
			informacion varchar  
			)
as  $$
begin 
	return query 
	select table_name,
		column_name,
		('select distinct nif,fecha,medico_id , '||' '||column_name||' from '||table_schema||'.'||table_name||' where '||column_name||' = 1 union')::varchar as consulta_sql
from information_schema.columns loop
where table_schema= 'protocolos_omi_vigentes'
	and column_name like 'consejeria_%'
	and data_type='numeric'
	and column_name similar to '%'|| filtro || '%';
end ;
$$ language 'plpgsql';



CREATE or replace FUNCTION usr_jesoto.tipo_de_campos(filtro text) 
returns 
	table (	informacion varchar  
			)
as  $$
begin 
	return query 
select distinct column_name::varchar as tipo_de_campos
from information_schema.columns loop
where table_schema= 'protocolos_omi_vigentes'
	and data_type='numeric'
	and column_name like  ('%'|| filtro || '%')::text  --'consejeria_%'
	order by 1	;
end ;
$$ language 'plpgsql';

select usr_jesoto.tipo_de_campos('consejeria'); 


-- drop FUNCTION usr_jesoto.tipo_de_campo2(varchar)
CREATE or replace FUNCTION usr_jesoto.tipo_de_campo2(text)
	returns 
		table (informacion varchar 
		)
as 
 $$
select distinct left (column_name,-12)||''||right(column_name,4)::varchar  as tipo_campo
from information_schema.columns loop
where table_schema= 'protocolos_omi_vigentes'
	--and data_type='numeric'
and  upper(column_name) like upper('%'|| $1 || '%')::text --upper('consejeria%')::text -- ('%'|| $1 || '%')  --'consejeria_%'
order by 1;
$$ 

select usr_jesoto.tipo_de_campo2('CONSEJERIA'); 


--drop FUNCTION usr_jesoto.consulta_sql(filtro varchar)
CREATE or replace FUNCTION usr_jesoto.consulta_sql(filtro varchar) 
returns 
	table (	informacion varchar  
			)
as  $$
begin 
	return query 
	select 
		('select distinct nif,fecha,medico_id , '||' '||column_name||' from '||table_schema||'.'||table_name||' where '||column_name||' = 1 union')::varchar
from information_schema.columns loop
where table_schema= 'protocolos_omi_vigentes'
	and column_name like 'consejeria_%'
	and data_type='numeric'
	and column_name similar to '%'|| $1 || '%';
end ;
$$ language 'plpgsql';


select usr_jesoto.consulta_sql('tabaquismo');


--drop FUNCTION usr_jesoto.mapping_consulta_sql(tb varchar ,campo varchar  ,filtro varchar)
--drop FUNCTION usr_jesoto.mapping_consulta_sql(filtro varchar ) 
CREATE or replace FUNCTION usr_jesoto.mapping_consulta_sql(filtro text) 
returns 
	table (protocolo varchar  ,
			campo varchar ,
			consulta_sql varchar  
			)
as  $$
begin 
	return query 
	select table_name::varchar as protocolo,
		column_name::varchar as campo,
		('select distinct nif,fecha,medico_id , '||' '||column_name||' from '||table_schema||'.'||table_name||' where '||column_name||' = 1 union')::varchar as consulta_sql
from information_schema.columns loop
where table_schema= 'protocolos_omi_vigentes'
	and column_name like 'consejeria_%'
	and data_type='numeric'
	and column_name like ('%'|| filtro || '%')::text ;
end ;
$$ language 'plpgsql';

select * from  usr_jesoto.mapping_consulta_sql('tabaquismo');
--select * from  usr_jesoto.mapping_consulta_sql(('tabaquismo')::varchar);
--select usr_jesoto.mapping_consulta_sql(('tabaquismo')::varchar);

select usr_jesoto.tipo_de_campos('consejeria');

select * from  usr_jesoto.mapping_consulta_sql('fisica');




-- drop  FUNCTION usr_jesoto.consulta_proto_campo(nproto int , ncampo int ) 
-- drop  FUNCTION usr_jesoto.consulta_proto_campo(nproto int) 
--CREATE or replace FUNCTION usr_jesoto.consulta_proto_campo(nproto int , ncampo int ) 
-- Si se sobrecarga, se podra generar dos consultas con otros parametros, en este caso , se podra consultar por 1 o 2 según sea el caso
CREATE or replace FUNCTION usr_jesoto.consulta_proto_campo(nproto int)
returns 
	table (informacion_proto int  ,
			informacion_numero int ,
			informacion_esquema text,
			informacion_nombre_columna text ,
			informacion_tipo_columna text ,
			informacion_consulta_sql text
			)
as  $$
begin 
	return query 
	select a.proto
			,a.numero
			,a.esquema
			--,a.tipo_campo
			,a.nombre_columna
			,a.tipo_columna
			--,a.nombre_protocolo
			--,a.nombre_columna
			,a.consulta_sql
	from (
select distinct right(table_name,6)::int as proto
			,right(left(column_name,-4),4)::int as numero
			,(table_schema||'.'||table_name)::text as esquema
			--,left (column_name,-12)||''||right(column_name,4)::text  as tipo_campo
			,column_name::text nombre_columna
			,case 	
				when right(column_name,1)='x' then 'X = Lista Desplegable - Formato Texto'
				when right(column_name,1)='n' then 'N = Numero - Formato numérico'
				when right(column_name,1)='s' then 'S = SI/NO - Formato numérico'
				when right(column_name,1)='o' then 'D = Formulas - Formato numérico'
				when right(column_name,1)='d' then 'D = Fechas - Formato Date'
				when right(column_name,1)='v' then 'V = Check - Formato numérico'
				when right(column_name,1)='f' then 'F = Fecha - Formato Date'
				when right(column_name,1)='t' then 'T = Texto - Formato Texto'
				when right(column_name,1)='c' then 'C = Texto - Formato Texto'
				else 'revisar'
			end::text  tipo_columna
		--	,table_name::text as nombre_protocolo
		--	,column_name::text as nombre_columna
			, case 
			when right(column_name,1) ='x'
				then 'select distinct nif,fecha,medico_id , '||' '||column_name||' from '||table_schema||'.'||table_name||' where '||column_name||' <>'''' ;'
			when right(column_name,1) ='f'
				then 'select distinct nif,fecha,medico_id , '||' '||column_name||' from '||table_schema||'.'||table_name||' where '||column_name||' is not null ;'
			when right(column_name,1) in ('t','c')
				then 'select distinct nif,fecha,medico_id , '||' '||column_name||' from '||table_schema||'.'||table_name||' where '||column_name||' <>'''' ;'
			else 'select distinct nif,fecha,medico_id , '||' '||column_name||' from '||table_schema||'.'||table_name||' where '||column_name||' = 1 ;' 
		end::text 	consulta_sql
			--,*
from information_schema.columns loop
where table_schema= 'protocolos_omi_vigentes'
and table_name not in ('dim_tblvar','dim_tablas','mapro_nomvar','mapro_nomtbl')
and right (column_name,3) in ('t_v' -- visto
							,'t_s' -- si/no
							,'t_n' --numerico
							,'t_x' -- tabla_contraste
							,'t_o' --formula
							,'t_t' --texto
							,'t_c' --comentario
							)
and right (column_name,3) not in ('t_f' --fecha_
							,'t_l' --talla_
							,'t_p' --peso
							,'t_z' --permietro_
							)
--) as a where (proto)::int =$1 and (numero)::int =$2;						
-- para sobre carga ejecutar de nuevo perpo con un or 
) as a where (proto)::int =$1; --or (numero)::int =$2;
end ;
$$ language 'plpgsql'
;

select * from  usr_jesoto.consulta_proto_campo(347);
select * from  usr_jesoto.consulta_proto_campo(347,128);












CREATE or replace FUNCTION usr_jesoto.consulta_proto_campo(nproto smallint , ncampo smallint ) 
returns 
	table (proto smallint  ,
			campo smallint ,
			informacion varchar ,
			nomprotocolo varchar ,
			nombrecolumna varchar
			)
as  $$
begin 
	return query 
select distinct right(table_name,6)::int as proto
			,right(left(column_name,-4),4)::int as wnumero
			,left (column_name,-12)||''||right(column_name,4)::varchar  as tipo_campo
			,table_name as nombre_protocolo
			,column_name as nombre_columna
from information_schema.columns loop
where table_schema= 'protocolos_omi_vigentes'
and table_name not in ('dim_tblvar','dim_tablas','mapro_nomvar','mapro_nomtbl')
and right (column_name,3) in ('t_v' -- visto
							,'t_s' -- si/no
							,'t_n' --numerico
							,'t_x' -- tabla_contraste
							,'t_o' --formula
							)
and right (column_name,3) not in ('t_f' --fecha_
							,'t_l' --talla_
							,'t_p' --peso
							,'t_z' --permietro_
							)
--and data_type='numeric'
--and  upper(column_name) like upper('control_pre%')::text --upper('%'|| $1 || '%')::text --upper('consejeria%')::text -- ('%'|| $1 || '%')  --'consejeria_%'
	and (right(table_name,6)::int = nproto
		or right(left(column_name,-4),4)::int = ncampo
		);
end ;
$$ language 'plpgsql'
;


-- drop FUNCTION usr_jesoto.consulta_proto_vigentes_sql(filtro text ) 
CREATE or replace FUNCTION usr_jesoto.consulta_proto_vigentes_sql(filtro text) 
returns 
	table (	informacion_esquema text ,
			informacion_nom_protocolo text  ,
			numero_proto int ,
			info_esquema_y_tabla text ,
			consulta_proto_sql text  
			)
as  $$
begin 
	return query 
	select a.esquema
		,a.protocolo
		,a.numproto
		,a.esquema_y_tabla
		,a.consulta_sql
	from  ( 
	select distinct table_schema::text as esquema,
			table_name::text as protocolo,
			right(table_name,6)::int as numproto,
			table_schema||'.'||table_name::text as esquema_y_tabla,
			('select distinct nif,fecha,medico_id from '||table_schema||'.'||table_name||' where fecha is not null and nif is not null ;')::text as consulta_sql
from information_schema.columns loop
where table_schema= 'protocolos_omi_vigentes'
	and data_type='numeric'
	and table_name not in ('dim_tblvar','dim_tablas','mapro_nomvar','mapro_nomtbl')
	and right (column_name,3) in ('t_v' -- visto
							,'t_s' -- si/no
							,'t_n' --numerico
							,'t_x' -- tabla_contraste
							,'t_o' --formula
							)
and right (column_name,3) not in ('t_f' --fecha_
							,'t_l' --talla_
							,'t_p' --peso
							,'t_z' --permietro_
							)
	) as a where esquema like ('%'|| $1 || '%')::text 
	order by 3
;
end ;
$$ language 'plpgsql';

select * from usr_jesoto.consulta_proto_vigentes_sql('protocolos_omi_vigentes');


-- drop FUNCTION usr_jesoto.busca_columna_sql(text)
CREATE FUNCTION usr_jesoto.busca_columna_sql(filtro text)
returns 
table ( info_schema_tabla text, 
		info_columna_nombre text,
		info_tipo_columna text ,
		info_consulta_sql text
		
)
as  $$
 begin 
	 return query 
select table_schema||'.'||table_name::text as esquema_tabla
		,column_name::text as columna_nombre
		,case 	
				when right(column_name,1)='x' then 'X = Lista Desplegable - Formato Texto'
				when right(column_name,1)='n' then 'N = Numero - Formato numérico'
				when right(column_name,1)='s' then 'S = SI/NO - Formato numérico'
				when right(column_name,1)='o' then 'D = Formulas - Formato numérico'
				when right(column_name,1)='d' then 'D = Fechas - Formato Date'
				when right(column_name,1)='v' then 'V = Check - Formato numérico'
				when right(column_name,1)='f' then 'F = Fecha - Formato Date'
				--when right(column_name,1)='t' then 'T = Texto - Formato Texto'
				else 'revisar'
		end::text  tipo_columna
		, case 
			when right(column_name,1) ='x'
				then 'select distinct nif,fecha,medico_id , '||' '||column_name||' from '||table_schema||'.'||table_name||' where '||column_name||' <>'''' ;'
			when right(column_name,1) ='f'
				then 'select distinct nif,fecha,medico_id , '||' '||column_name||' from '||table_schema||'.'||table_name||' where '||column_name||' is not null ;'
			when right(column_name,1) ='t'
				then 'select distinct nif,fecha,medico_id , '||' '||column_name||' from '||table_schema||'.'||table_name||' where '||column_name||' <>'''' ;'
			else 'select distinct nif,fecha,medico_id , '||' '||column_name||' from '||table_schema||'.'||table_name||' where '||column_name||' = 1 ;' 
		end::text 	consulta_sql
from information_schema.columns 
where table_schema= 'protocolos_omi_vigentes'
and column_name similar to ('%'|| $1 || '%')::text;
end 
$$ 
language plpgsql;

select * from usr_jesoto.busca_columna_sql('transmision_vertical');


-- drop FUNCTION usr_jesoto.consejeria_consulta_sql(varchar)
CREATE FUNCTION usr_jesoto.consejeria_consulta_sql(varchar) 
returns 
		table (info_consulta_sql_consejeria varchar 
		)
as 
 $$
select 'select distinct nif,fecha,medico_id , '||' '||column_name||' from '||table_schema||'.'||table_name||' where '||column_name||' = 1 union' as consulta_sql
from information_schema.columns 
where table_schema= 'protocolos_omi_vigentes'
and data_type='numeric'
and column_name like 'consejeria_%'
and column_name like '%'||$1 ||'%' --'%tabaquismo%'
$$ 
language sql;

select usr_jesoto.consejeria_consulta_sql('alimen');


/*DATOS SENAME  para reemplazar consulta con parametros*/
--drop function  usr_jesoto.sename(int) 
CREATE FUNCTION usr_jesoto.sename(int) returns int 
as 
$$ 

select distinct sename from usr_jesoto.sename_actual where nif2 is not null and nif2 =$1;
		
$$ 
language sql
; 

select  usr_jesoto.sename(161422) ;