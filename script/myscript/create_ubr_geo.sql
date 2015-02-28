--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET search_path = ubr_geo, public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: maps; Type: TABLE; Schema: ubr_geo; Owner: ubr_geo; Tablespace: 
--

CREATE TABLE ubr_geo.maps (
    map_id integer NOT NULL,
    filename character varying(80),
    boundary_id integer,
    resolution smallint,
    mab100 character varying(255),
    mab104 character varying(50),
    mab108 character varying(50),
    mab112 character varying(50),
    mab331 character varying(255),
    scale double precision,
    mab400 character varying(255),
    mab410 character varying(100),
    mab425a character varying(100),
    year character varying(50),
    mab451 character varying(255),
    mab590a character varying(255),
    is_side_map smallint,
    u_mab089 character varying(50),
    u_mab331 character varying(255),
    call_number character varying(50),
    serial_id integer,
    url character varying(255),
    pixel_x integer,
    pixel_y integer,
    CONSTRAINT filename UNIQUE(filename)
);


ALTER TABLE ubr_geo.maps OWNER TO ubr_geo;

--
-- Name: maps_map_id_seq; Type: SEQUENCE; Schema: ubr_geo; Owner: ubr_geo
--

CREATE SEQUENCE ubr_geo.maps_map_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ubr_geo.maps_map_id_seq OWNER TO ubr_geo;

--
-- Name: maps_map_id_seq; Type: SEQUENCE OWNED BY; Schema: ubr_geo; Owner: ubr_geo
--

ALTER SEQUENCE ubr_geo.maps_map_id_seq OWNED BY ubr_geo.maps.map_id;


--
-- Name: map_id; Type: DEFAULT; Schema: ubr_geo; Owner: ubr_geo
--

ALTER TABLE ONLY ubr_geo.maps ALTER COLUMN map_id SET DEFAULT nextval('maps_map_id_seq'::regclass);


--
-- Name: maps_pkey; Type: CONSTRAINT; Schema: ubr_geo; Owner: ubr_geo; Tablespace: 
--

ALTER TABLE ONLY ubr_geo.maps
    ADD CONSTRAINT maps_pkey PRIMARY KEY (map_id);

--
-- Name: boundaries; Type: TABLE; Schema: ubr_geo; Owner: ubr_geo; Tablespace: 
--

CREATE TABLE ubr_geo.boundaries (
    fid integer NOT NULL,
    boundary_wld geometry(MultiPolygon,3857),
    boundary_px  geometry(MultiPolygon,0)
);

ALTER TABLE ubr_geo.boundaries OWNER TO ubr_geo;

--
-- Name: boundaries_fid_seq; Type: SEQUENCE; Schema: ubr_geo; Owner: ubr_geo
--

CREATE SEQUENCE ubr_geo.boundaries_fid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ubr_geo.boundaries_fid_seq OWNER TO ubr_geo;

--
-- Name: boundaries_fid_seq; Type: SEQUENCE OWNED BY; Schema: ubr_geo; Owner: ubr_geo
--

ALTER SEQUENCE ubr_geo.boundaries_fid_seq OWNED BY ubr_geo.boundaries.fid;


--
-- Name: fid; Type: DEFAULT; Schema: public; Owner: ubr_geo
--

ALTER TABLE ONLY ubr_geo.boundaries ALTER COLUMN fid SET DEFAULT nextval('boundaries_fid_seq'::regclass);


--
-- Name: boundaries_pkey; Type: CONSTRAINT; Schema: public; Owner: ubr_geo; Tablespace: 
--

ALTER TABLE ONLY ubr_geo.boundaries
    ADD CONSTRAINT boundaries_pkey PRIMARY KEY (fid);


--
-- Name: boundaries_boundary_wld_geom_idx; Type: INDEX; Schema: ubr_geo; Owner: ubr_geo; Tablespace: 
--

CREATE INDEX boundaries_boundary_wld_geom_idx ON ubr_geo.boundaries USING gist (boundary_wld);


--
-- Name: boundaries_boundary_px_geom_idx; Type: INDEX; Schema: ubr_geo; Owner: ubr_geo; Tablespace: 
--

CREATE INDEX boundaries_boundary_px_geom_idx ON ubr_geo.boundaries USING gist (boundary_px);

--
--
-- Name: fk_maps_boundaries; Type: FK CONSTRAINT; Schema: ubr_geo; Owner: ubr_geo
--

ALTER TABLE ONLY ubr_geo.maps
    ADD CONSTRAINT fk_maps_boundaries FOREIGN KEY (boundary_id) REFERENCES ubr_geo.boundaries(fid) ON UPDATE CASCADE ON DELETE RESTRICT;

--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA ubr_geo FROM PUBLIC;
REVOKE ALL ON SCHEMA ubr_geo FROM postgres;
GRANT ALL ON SCHEMA ubr_geo TO postgres;
GRANT ALL ON SCHEMA ubr_geo TO PUBLIC;


--
-- PostgreSQL database dump complete
--

