CREATE TABLE ubr_geo.transforms (
    map_id integer NOT NULL,
    upperleft_x double precision,
    scale_x double precision,
    skew_y double precision,
    upperleft_y double precision,
    skew_x double precision,
    scale_y double precision,
    srid integer NOT NULL
);

ALTER TABLE ubr_geo.transforms OWNER TO ubr_geo;

--
-- Name: fk_transforms_maps; Type: FK CONSTRAINT; Schema: ubr_geo; Owner: ubr_geo
--

ALTER TABLE ONLY ubr_geo.transforms
    ADD CONSTRAINT fk_transforms_maps FOREIGN KEY (map_id) REFERENCES ubr_geo.maps(map_id) ON UPDATE CASCADE ON DELETE RESTRICT;

--
-- Name: fk_gcps_spatial_ref_sys; Type: FK CONSTRAINT; Schema: ubr_geo; Owner: ubr_geo
--

ALTER TABLE ONLY ubr_geo.transforms
    ADD CONSTRAINT fk_transforms_spatial_ref_sys FOREIGN KEY (srid) REFERENCES spatial_ref_sys(srid) ON UPDATE CASCADE ON DELETE RESTRICT;
