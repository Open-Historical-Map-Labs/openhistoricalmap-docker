--DROP FUNCTION tile_for_point (integer, integer, integer);
CREATE OR REPLACE FUNCTION tile_for_point(
integer,
integer
) RETURNS integer AS $tile_for_point$
DECLARE
v_lat ALIAS FOR $1;
v_lon ALIAS FOR $2;
v_lat_float double precision;
v_lon_float double precision;
v_lat2y bigint;
v_lon2x bigint;
v_tile bigint;
i integer;
j integer;
BEGIN
v_lat_float := v_lat / 10000000.0;
v_lon_float := v_lon / 10000000.0;
v_tile := 0;

SELECT round((v_lat_float + 90.0) * 65535.0 / 180.0) INTO v_lat2y;
SELECT round((v_lon_float + 180.0) * 65535.0 / 360.0) INTO v_lon2x;
FOR j IN 0..15 LOOP
  i := 15 - j;
  SELECT (v_tile << 1) | ((v_lon2x >> i) & 1) INTO v_tile;
  SELECT (v_tile << 1) | ((v_lat2y >> i) & 1) INTO v_tile;
  END LOOP;

  RETURN v_tile;
END;
$tile_for_point$ LANGUAGE plpgsql

