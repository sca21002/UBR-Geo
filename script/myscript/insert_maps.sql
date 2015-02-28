INSERT INTO ubr_geo.maps
    (
    filename, boundary_id, resolution, mab100, mab104, mab108, mab112, mab331, scale,
    mab400, mab410, mab425a, year, mab451, mab590a, is_side_map, u_mab089, u_mab331, call_number,
    serial_id, url, pixel_x, pixel_y
    ) 
SELECT 
    worldfile, boundary_id, 400 ,       mab100, mab104, mab108, mab112, mab331, scale,
    mab400, mab410, mab425a, year, mab451, mab590a, is_side_map, u_mab089, u_mab331, call_number,
    serial_id, url, pixel_x, pixel_y
    from blo.maps;
  
