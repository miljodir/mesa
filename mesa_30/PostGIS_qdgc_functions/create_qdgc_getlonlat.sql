-- FUNCTION: public.qdgc_getlonlat(double precision, double precision)

-- DROP FUNCTION IF EXISTS public.qdgc_getlonlat(double precision, double precision);

CREATE OR REPLACE FUNCTION public.qdgc_getlonlat(
	lon_value double precision,
	lat_value double precision)
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$

DECLARE
    lon_string VARCHAR(50);
    lat_string VARCHAR(50);
    square VARCHAR(50);
BEGIN
if lon_value < 0 then
    square := 'W';
else
    square := 'E';
END if;

lon_string := TO_CHAR(lon_value, 'fm000');
square := CONCAT(square, lon_string);

if  lat_value < 0 then
    square := CONCAT(square, 'S');
else
    square := CONCAT(square, 'N');
END if;

lat_string := TO_CHAR(lat_value, 'fm00');
square := CONCAT(square, lat_string);
return square;

END 
$BODY$;

ALTER FUNCTION public.qdgc_getlonlat(double precision, double precision)
    OWNER TO mesa;
