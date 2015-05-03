CREATE TABLE ubr_geo.libraries (
    ISIL character varying(16) not NULL,
    name character varying(255),
    info text
);

ALTER TABLE ubr_geo.libraries OWNER TO ubr_geo;


--
-- Name: libraries_pkey; Type: CONSTRAINT; Schema: ubr_geo; Owner: ubr_geo; Tablespace: 
--

ALTER TABLE ONLY ubr_geo.libraries
    ADD CONSTRAINT libraries_pkey PRIMARY KEY (ISIL);


ALTER TABLE ubr_geo.maps ADD COLUMN ISIL character varying(16);

--
-- Name: fk_libraries_maps; Type: FK CONSTRAINT; Schema: ubr_geo; Owner: ubr_geo
--

ALTER TABLE ONLY ubr_geo.maps
    ADD CONSTRAINT fk_maps_libraries FOREIGN KEY (ISIL) REFERENCES ubr_geo.libraries(ISIL) ON UPDATE CASCADE ON DELETE RESTRICT;

