CREATE TABLE ubr_geo.gcps (
    id integer not NULL,    
    map_id integer NOT NULL,
    x double precision,
    y double precision,
    z double precision,
    "column" double precision,
    row double precision,
    info character varying(255)
);

ALTER TABLE ubr_geo.gcps OWNER TO ubr_geo;

--
-- Name: gcps_id_seq; Type: SEQUENCE; Schema: ubr_geo; Owner: ubr_geo
--

CREATE SEQUENCE ubr_geo.gcps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ubr_geo.gcps_id_seq OWNER TO ubr_geo;

--
-- Name: gcps_id_seq; Type: SEQUENCE OWNED BY; Schema: ubr_geo; Owner: ubr_geo
--

ALTER SEQUENCE ubr_geo.gcps_id_seq OWNED BY ubr_geo.gcps.id;


--
-- Name: id; Type: DEFAULT; Schema: ubr_geo; Owner: ubr_geo
--

ALTER TABLE ONLY ubr_geo.gcps ALTER COLUMN id SET DEFAULT nextval('gcps_id_seq'::regclass);


--
-- Name: gcps_pkey; Type: CONSTRAINT; Schema: ubr_geo; Owner: ubr_geo; Tablespace: 
--

ALTER TABLE ONLY ubr_geo.gcps
    ADD CONSTRAINT gcps_pkey PRIMARY KEY (id);


--
-- Name: fk_gcps_maps; Type: FK CONSTRAINT; Schema: ubr_geo; Owner: ubr_geo
--

ALTER TABLE ONLY ubr_geo.gcps
    ADD CONSTRAINT fk_gcps_maps FOREIGN KEY (map_id) REFERENCES ubr_geo.maps(map_id) ON UPDATE CASCADE ON DELETE RESTRICT;

