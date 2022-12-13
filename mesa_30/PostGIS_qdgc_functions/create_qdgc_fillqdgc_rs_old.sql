-- FUNCTION: public.qdgc_fillqdgc_rs(text, integer, integer, text, geometry)

-- DROP FUNCTION IF EXISTS public.qdgc_fillqdgc_rs(text, integer, integer, text, geometry);

CREATE OR REPLACE FUNCTION public.qdgc_fillqdgc_rs(
	area_name text,
	qdgc_level integer,
	purge integer,
	project_schema text,
	area_poly geometry)
    RETURNS SETOF text 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
declare
	returnstring text;
	temp_row text;
	lonlat text;
	"id" text;
begin

EXECUTE format('SET search_path TO %I, public', project_schema);  -- only for this transaction

	if purge=1 then
        drop table if exists tbl_geocode_object;
        create table tbl_geocode_object ("id" varchar(40), area_reference varchar(50),level_qdgc int, cellsize_degrees decimal, lon_center decimal, lat_center decimal, area_km2 decimal, geom geometry);
	end if;

   	/* Establishing counter which defindes the depth of the grid cell creation. Here from 1 (1/2 degree) to 5 (1/32 degree) */
    for counter in 1..qdgc_level loop
	

   		with grid as (
			/* creating the grid */
			select (st_squaregrid((1/(2^counter)), st_transform(area_poly,4326))).* ,area_name as area_reference
			) 
			insert into tbl_geocode_object
			select qdgc_getqdgc(ST_X(ST_Centroid(geom)),ST_Y(ST_Centroid(geom)),counter),area_reference,counter,(1/(2^counter)), ST_X(ST_Centroid(geom)),ST_Y(ST_Centroid(geom)),(st_area(st_transform(geom, 102022))/1000000), geom from grid;
   		end loop;
	end
    
$BODY$;

ALTER FUNCTION public.qdgc_fillqdgc_rs(text, integer, integer, text, geometry)
    OWNER TO mesa;
