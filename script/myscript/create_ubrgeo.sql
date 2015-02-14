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


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: maps; Type: TABLE; Schema: public; Owner: ubrgeo; Tablespace: 
--

CREATE TABLE maps (
    fid integer NOT NULL,
    boundary_wld geometry(Polygon,3857),
    boundary_px  geometry(Polygon,-1),
    filename character varying(80),
    resolution smallint,
    scale double precision,
    CONSTRAINT filename UNIQUE(filename)
);


ALTER TABLE public.maps OWNER TO ubrgeo;

--
-- Name: maps_fid_seq; Type: SEQUENCE; Schema: public; Owner: ubrgeo
--

CREATE SEQUENCE maps_fid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.maps_fid_seq OWNER TO ubrgeo;

--
-- Name: maps_fid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ubrgeo
--

ALTER SEQUENCE maps_fid_seq OWNED BY maps.fid;


--
-- Name: fid; Type: DEFAULT; Schema: public; Owner: ubrgeo
--

ALTER TABLE ONLY maps ALTER COLUMN fid SET DEFAULT nextval('maps_fid_seq'::regclass);


--
-- Name: maps_pkey; Type: CONSTRAINT; Schema: public; Owner: ubrgeo; Tablespace: 
--

ALTER TABLE ONLY maps
    ADD CONSTRAINT maps_pkey PRIMARY KEY (fid);


--
-- Name: maps_boundary_wld_geom_idx; Type: INDEX; Schema: public; Owner: ubrgeo; Tablespace: 
--

CREATE INDEX maps_boundary_wld_geom_idx ON maps USING gist (boundary_wld);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

--
-- Name: maps_boundary_px_geom_idx; Type: INDEX; Schema: public; Owner: ubrgeo; Tablespace: 
--

CREATE INDEX maps_boundary_px_geom_idx ON maps USING gist (boundary_px);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

