--DROP FUNCTION maptile_for_point (integer, integer, integer);
CREATE OR REPLACE FUNCTION maptile_for_point(
  integer,
  integer,
  integer
) RETURNS integer AS $maptile_for_point$


DECLARE
  v_lat ALIAS FOR $1;
  v_lon ALIAS FOR $2;
  v_zoom ALIAS FOR $3;
  v_lat_float double precision;
  v_lon_float double precision;
  v_scale double precision;
  v_r_per_d double precision;
  v_x bigint;
  v_y bigint;
  v_maptile integer;
BEGIN
  -- Set some values
    v_lat_float := v_lat / 10000000.0;
    v_lon_float := v_lon / 10000000.0;
    v_scale := pow(2, v_zoom);

    SELECT PI()/180 INTO v_r_per_d;

    SELECT floor((v_lon_float + 180.0) * v_scale / 360.0)
     INTO v_x;                                                            `
    SELECT floor((1 - log(tan(v_lat_float * v_r_per_d) +
     1.0 / cos(v_lat_float * v_r_per_d)) / PI()) * v_scale / 2.0) INTO v_y;`
    SELECT ((v_x << v_zoom) | v_y) INTO v_maptile;
  RETURN v_maptile;

END;
$maptile_for_point$ LANGUAGE plpgsql;
