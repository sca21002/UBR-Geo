CREATE TABLE ubr_geo.projects (
    id integer not NULL,
    short character varying(25),
    name character varying(255),
    info text
);

ALTER TABLE ubr_geo.projects OWNER TO ubr_geo;

--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: ubr_geo; Owner: ubr_geo
--

CREATE SEQUENCE ubr_geo.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE ubr_geo.projects_id_seq OWNER TO ubr_geo;

--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: ubr_geo; Owner: ubr_geo
--

ALTER SEQUENCE ubr_geo.projects_id_seq OWNED BY ubr_geo.projects.id;


--
-- Name: id; Type: DEFAULT; Schema: ubr_geo; Owner: ubr_geo
--

ALTER TABLE ONLY ubr_geo.projects ALTER COLUMN id SET DEFAULT nextval('projects_id_seq'::regclass);


--
-- Name: projects_pkey; Type: CONSTRAINT; Schema: ubr_geo; Owner: ubr_geo; Tablespace: 
--

ALTER TABLE ONLY ubr_geo.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


ALTER TABLE ubr_geo.maps ADD COLUMN project_id integer;

--
-- Name: fk_projects_maps; Type: FK CONSTRAINT; Schema: ubr_geo; Owner: ubr_geo
--

ALTER TABLE ONLY ubr_geo.maps
    ADD CONSTRAINT fk_maps_projects FOREIGN KEY (project_id) REFERENCES ubr_geo.projects(id) ON UPDATE CASCADE ON DELETE RESTRICT;

