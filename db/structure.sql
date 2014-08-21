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
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: analyses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE analyses (
    id integer NOT NULL,
    game_id integer,
    status text,
    job_id integer,
    error_message text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: analyses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE analyses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analyses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE analyses_id_seq OWNED BY analyses.id;


--
-- Name: analysis_scripts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE analysis_scripts (
    id integer NOT NULL,
    "verbose" boolean,
    regret numeric,
    dist numeric,
    support numeric,
    converge numeric,
    iters integer,
    points integer,
    analysis_id integer,
    enable_dominance boolean,
    output json,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: analysis_scripts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE analysis_scripts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: analysis_scripts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE analysis_scripts_id_seq OWNED BY analysis_scripts.id;


--
-- Name: control_variables; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE control_variables (
    id integer NOT NULL,
    simulator_instance_id integer NOT NULL,
    name character varying(255) NOT NULL,
    expectation double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: control_variables_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE control_variables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: control_variables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE control_variables_id_seq OWNED BY control_variables.id;


--
-- Name: control_variate_states; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE control_variate_states (
    id integer NOT NULL,
    simulator_instance_id integer,
    state character varying(255) DEFAULT 'none'::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: control_variate_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE control_variate_states_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: control_variate_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE control_variate_states_id_seq OWNED BY control_variate_states.id;


--
-- Name: dominance_scripts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE dominance_scripts (
    id integer NOT NULL,
    output json,
    analysis_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: dominance_scripts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dominance_scripts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dominance_scripts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dominance_scripts_id_seq OWNED BY dominance_scripts.id;


--
-- Name: games; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE games (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    size integer NOT NULL,
    simulator_instance_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    subgames json
);


--
-- Name: games_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE games_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: games_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE games_id_seq OWNED BY games.id;


--
-- Name: observation_aggs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE observation_aggs (
    id integer NOT NULL,
    observation_id integer NOT NULL,
    symmetry_group_id integer NOT NULL,
    payoff double precision NOT NULL,
    payoff_sd double precision,
    adjusted_payoff double precision,
    adjusted_payoff_sd double precision
);


--
-- Name: observation_aggs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE observation_aggs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: observation_aggs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE observation_aggs_id_seq OWNED BY observation_aggs.id;


--
-- Name: observations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE observations (
    id integer NOT NULL,
    profile_id integer NOT NULL,
    extended_features json,
    created_at timestamp without time zone,
    features hstore
);


--
-- Name: observations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE observations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: observations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE observations_id_seq OWNED BY observations.id;


--
-- Name: pbs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pbs (
    id integer NOT NULL,
    day integer,
    hour integer,
    minute integer,
    memory integer,
    memory_unit text,
    analysis_id integer,
    scripts text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: pbs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pbs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pbs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pbs_id_seq OWNED BY pbs.id;


--
-- Name: player_control_variables; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE player_control_variables (
    id integer NOT NULL,
    simulator_instance_id integer NOT NULL,
    name character varying(255) NOT NULL,
    coefficient double precision DEFAULT 0 NOT NULL,
    expectation double precision,
    role character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: player_control_variables_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE player_control_variables_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: player_control_variables_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE player_control_variables_id_seq OWNED BY player_control_variables.id;


--
-- Name: players; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE players (
    id integer NOT NULL,
    payoff double precision NOT NULL,
    extended_features json,
    observation_id integer NOT NULL,
    symmetry_group_id integer NOT NULL,
    created_at timestamp without time zone,
    adjusted_payoff double precision,
    features hstore
);


--
-- Name: players_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE players_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: players_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE players_id_seq OWNED BY players.id;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE profiles (
    id integer NOT NULL,
    simulator_instance_id integer NOT NULL,
    size integer NOT NULL,
    observations_count integer DEFAULT 0 NOT NULL,
    assignment text NOT NULL,
    role_configuration hstore NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profiles_id_seq OWNED BY profiles.id;


--
-- Name: reduction_scripts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reduction_scripts (
    id integer NOT NULL,
    mode text,
    reduced_number_hash json,
    analysis_id integer,
    output json,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: reduction_scripts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reduction_scripts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reduction_scripts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reduction_scripts_id_seq OWNED BY reduction_scripts.id;


--
-- Name: role_coefficients; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE role_coefficients (
    id integer NOT NULL,
    control_variable_id integer NOT NULL,
    role text NOT NULL,
    coefficient double precision DEFAULT 0.0
);


--
-- Name: role_coefficients_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE role_coefficients_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: role_coefficients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE role_coefficients_id_seq OWNED BY role_coefficients.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    count integer NOT NULL,
    reduced_count integer NOT NULL,
    name character varying(255) NOT NULL,
    role_owner_id integer NOT NULL,
    role_owner_type character varying(255) NOT NULL,
    strategies character varying(255)[],
    deviating_strategies character varying(255)[],
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: schedulers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schedulers (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    active boolean DEFAULT false NOT NULL,
    process_memory integer NOT NULL,
    time_per_observation integer NOT NULL,
    observations_per_simulation integer DEFAULT 10 NOT NULL,
    default_observation_requirement integer DEFAULT 10 NOT NULL,
    nodes integer DEFAULT 1 NOT NULL,
    size integer NOT NULL,
    simulator_instance_id integer NOT NULL,
    type character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: schedulers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE schedulers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schedulers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE schedulers_id_seq OWNED BY schedulers.id;


--
-- Name: scheduling_requirements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scheduling_requirements (
    id integer NOT NULL,
    count integer NOT NULL,
    scheduler_id integer NOT NULL,
    profile_id integer NOT NULL,
    created_at timestamp without time zone
);


--
-- Name: scheduling_requirements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scheduling_requirements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: scheduling_requirements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scheduling_requirements_id_seq OWNED BY scheduling_requirements.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: simulations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE simulations (
    id integer NOT NULL,
    profile_id integer NOT NULL,
    scheduler_id integer NOT NULL,
    size integer NOT NULL,
    state character varying(255) DEFAULT 'pending'::character varying NOT NULL,
    job_id integer,
    error_message character varying(255),
    qos character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: simulations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE simulations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: simulations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE simulations_id_seq OWNED BY simulations.id;


--
-- Name: simulator_instances; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE simulator_instances (
    id integer NOT NULL,
    configuration hstore,
    simulator_id integer NOT NULL,
    simulator_fullname character varying(255) NOT NULL,
    created_at timestamp without time zone
);


--
-- Name: simulator_instances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE simulator_instances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: simulator_instances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE simulator_instances_id_seq OWNED BY simulator_instances.id;


--
-- Name: simulators; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE simulators (
    id integer NOT NULL,
    name character varying(32) NOT NULL,
    version character varying(32) NOT NULL,
    email character varying(255) NOT NULL,
    source character varying(255) NOT NULL,
    configuration hstore NOT NULL,
    role_configuration text DEFAULT '{}'::text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: simulators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE simulators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: simulators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE simulators_id_seq OWNED BY simulators.id;


--
-- Name: subgame_scripts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subgame_scripts (
    id integer NOT NULL,
    subgame text,
    reduced_number_hash json,
    analysis_id integer,
    output json,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: subgame_scripts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subgame_scripts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subgame_scripts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subgame_scripts_id_seq OWNED BY subgame_scripts.id;


--
-- Name: symmetry_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE symmetry_groups (
    id integer NOT NULL,
    profile_id integer NOT NULL,
    role character varying(255) NOT NULL,
    strategy character varying(255) NOT NULL,
    count integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    payoff double precision,
    payoff_sd double precision,
    adjusted_payoff double precision,
    adjusted_payoff_sd double precision,
    sum_sq_diff double precision,
    adj_sum_sq_diff double precision,
    observation_aggs_count integer DEFAULT 0 NOT NULL
);


--
-- Name: symmetry_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE symmetry_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: symmetry_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE symmetry_groups_id_seq OWNED BY symmetry_groups.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    authentication_token character varying(255),
    admin boolean DEFAULT false NOT NULL,
    approved boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY analyses ALTER COLUMN id SET DEFAULT nextval('analyses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY analysis_scripts ALTER COLUMN id SET DEFAULT nextval('analysis_scripts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY control_variables ALTER COLUMN id SET DEFAULT nextval('control_variables_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY control_variate_states ALTER COLUMN id SET DEFAULT nextval('control_variate_states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dominance_scripts ALTER COLUMN id SET DEFAULT nextval('dominance_scripts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY games ALTER COLUMN id SET DEFAULT nextval('games_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY observation_aggs ALTER COLUMN id SET DEFAULT nextval('observation_aggs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY observations ALTER COLUMN id SET DEFAULT nextval('observations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pbs ALTER COLUMN id SET DEFAULT nextval('pbs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY player_control_variables ALTER COLUMN id SET DEFAULT nextval('player_control_variables_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY players ALTER COLUMN id SET DEFAULT nextval('players_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles ALTER COLUMN id SET DEFAULT nextval('profiles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reduction_scripts ALTER COLUMN id SET DEFAULT nextval('reduction_scripts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY role_coefficients ALTER COLUMN id SET DEFAULT nextval('role_coefficients_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY schedulers ALTER COLUMN id SET DEFAULT nextval('schedulers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY scheduling_requirements ALTER COLUMN id SET DEFAULT nextval('scheduling_requirements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY simulations ALTER COLUMN id SET DEFAULT nextval('simulations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY simulator_instances ALTER COLUMN id SET DEFAULT nextval('simulator_instances_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY simulators ALTER COLUMN id SET DEFAULT nextval('simulators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY subgame_scripts ALTER COLUMN id SET DEFAULT nextval('subgame_scripts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY symmetry_groups ALTER COLUMN id SET DEFAULT nextval('symmetry_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: analyses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY analyses
    ADD CONSTRAINT analyses_pkey PRIMARY KEY (id);


--
-- Name: analysis_scripts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY analysis_scripts
    ADD CONSTRAINT analysis_scripts_pkey PRIMARY KEY (id);


--
-- Name: control_variables_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY control_variables
    ADD CONSTRAINT control_variables_pkey PRIMARY KEY (id);


--
-- Name: control_variate_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY control_variate_states
    ADD CONSTRAINT control_variate_states_pkey PRIMARY KEY (id);


--
-- Name: dominance_scripts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY dominance_scripts
    ADD CONSTRAINT dominance_scripts_pkey PRIMARY KEY (id);


--
-- Name: games_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY games
    ADD CONSTRAINT games_pkey PRIMARY KEY (id);


--
-- Name: observation_aggs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY observation_aggs
    ADD CONSTRAINT observation_aggs_pkey PRIMARY KEY (id);


--
-- Name: observations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY observations
    ADD CONSTRAINT observations_pkey PRIMARY KEY (id);


--
-- Name: pbs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pbs
    ADD CONSTRAINT pbs_pkey PRIMARY KEY (id);


--
-- Name: player_control_variables_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY player_control_variables
    ADD CONSTRAINT player_control_variables_pkey PRIMARY KEY (id);


--
-- Name: players_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: reduction_scripts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reduction_scripts
    ADD CONSTRAINT reduction_scripts_pkey PRIMARY KEY (id);


--
-- Name: role_coefficients_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY role_coefficients
    ADD CONSTRAINT role_coefficients_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schedulers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY schedulers
    ADD CONSTRAINT schedulers_pkey PRIMARY KEY (id);


--
-- Name: scheduling_requirements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scheduling_requirements
    ADD CONSTRAINT scheduling_requirements_pkey PRIMARY KEY (id);


--
-- Name: simulations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY simulations
    ADD CONSTRAINT simulations_pkey PRIMARY KEY (id);


--
-- Name: simulator_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY simulator_instances
    ADD CONSTRAINT simulator_instances_pkey PRIMARY KEY (id);


--
-- Name: simulators_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY simulators
    ADD CONSTRAINT simulators_pkey PRIMARY KEY (id);


--
-- Name: subgame_scripts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subgame_scripts
    ADD CONSTRAINT subgame_scripts_pkey PRIMARY KEY (id);


--
-- Name: symmetry_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY symmetry_groups
    ADD CONSTRAINT symmetry_groups_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_control_variables_on_simulator_instance_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_control_variables_on_simulator_instance_id ON control_variables USING btree (simulator_instance_id);


--
-- Name: index_control_variate_states_on_simulator_instance_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_control_variate_states_on_simulator_instance_id ON control_variate_states USING btree (simulator_instance_id);


--
-- Name: index_games_on_simulator_instance_id_and_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_games_on_simulator_instance_id_and_name ON games USING btree (simulator_instance_id, name);


--
-- Name: index_observation_aggs_on_observation_id_and_symmetry_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_observation_aggs_on_observation_id_and_symmetry_group_id ON observation_aggs USING btree (observation_id, symmetry_group_id);


--
-- Name: index_profiles_on_simulator_instance_id_and_assignment; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_profiles_on_simulator_instance_id_and_assignment ON profiles USING btree (simulator_instance_id, assignment);


--
-- Name: index_role_coefficients_on_control_variable_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_role_coefficients_on_control_variable_id ON role_coefficients USING btree (control_variable_id);


--
-- Name: index_roles_on_role_owner_id_and_role_owner_type_and_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_roles_on_role_owner_id_and_role_owner_type_and_name ON roles USING btree (role_owner_id, role_owner_type, name);


--
-- Name: index_schedulers_on_simulator_instance_id_and_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_schedulers_on_simulator_instance_id_and_name ON schedulers USING btree (simulator_instance_id, name);


--
-- Name: index_scheduling_requirements_on_profile_id_and_scheduler_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_scheduling_requirements_on_profile_id_and_scheduler_id ON scheduling_requirements USING btree (profile_id, scheduler_id);


--
-- Name: index_scheduling_requirements_on_scheduler_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_scheduling_requirements_on_scheduler_id ON scheduling_requirements USING btree (scheduler_id);


--
-- Name: index_simulations_on_profile_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_simulations_on_profile_id ON simulations USING btree (profile_id);


--
-- Name: index_simulator_instances_on_simulator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_simulator_instances_on_simulator_id ON simulator_instances USING btree (simulator_id);


--
-- Name: index_simulators_on_name_and_version; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_simulators_on_name_and_version ON simulators USING btree (name, version);


--
-- Name: index_symmetry_groups_on_profile_id_and_role_and_strategy; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_symmetry_groups_on_profile_id_and_role_and_strategy ON symmetry_groups USING btree (profile_id, role, strategy);


--
-- Name: index_users_on_admin; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_admin ON users USING btree (admin);


--
-- Name: index_users_on_approved; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_approved ON users USING btree (approved);


--
-- Name: index_users_on_authentication_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_authentication_token ON users USING btree (authentication_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: obs_feat_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX obs_feat_idx ON observations USING gin (features);


--
-- Name: pcv_sid_role_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX pcv_sid_role_index ON player_control_variables USING btree (simulator_instance_id, role);


--
-- Name: player_feat_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX player_feat_idx ON players USING gin (features);


--
-- Name: profiles_gin_role_configuration; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX profiles_gin_role_configuration ON profiles USING gin (role_configuration);


--
-- Name: simulator_instances_gin_configuration; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX simulator_instances_gin_configuration ON simulator_instances USING gin (configuration);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20130412192453');

INSERT INTO schema_migrations (version) VALUES ('20130416192544');

INSERT INTO schema_migrations (version) VALUES ('20130416200142');

INSERT INTO schema_migrations (version) VALUES ('20130417191928');

INSERT INTO schema_migrations (version) VALUES ('20130417195118');

INSERT INTO schema_migrations (version) VALUES ('20130417195937');

INSERT INTO schema_migrations (version) VALUES ('20130417200417');

INSERT INTO schema_migrations (version) VALUES ('20130417214256');

INSERT INTO schema_migrations (version) VALUES ('20130417214446');

INSERT INTO schema_migrations (version) VALUES ('20130417214621');

INSERT INTO schema_migrations (version) VALUES ('20130417214918');

INSERT INTO schema_migrations (version) VALUES ('20130418124854');

INSERT INTO schema_migrations (version) VALUES ('20130424233213');

INSERT INTO schema_migrations (version) VALUES ('20130719220509');

INSERT INTO schema_migrations (version) VALUES ('20130723220840');

INSERT INTO schema_migrations (version) VALUES ('20130724193439');

INSERT INTO schema_migrations (version) VALUES ('20130724202757');

INSERT INTO schema_migrations (version) VALUES ('20130724204644');

INSERT INTO schema_migrations (version) VALUES ('20130725194015');

INSERT INTO schema_migrations (version) VALUES ('20130731191218');

INSERT INTO schema_migrations (version) VALUES ('20130812174745');

INSERT INTO schema_migrations (version) VALUES ('20130814192102');

INSERT INTO schema_migrations (version) VALUES ('20130818192416');

INSERT INTO schema_migrations (version) VALUES ('20140226200433');

INSERT INTO schema_migrations (version) VALUES ('20140227181135');

INSERT INTO schema_migrations (version) VALUES ('20140228183427');

INSERT INTO schema_migrations (version) VALUES ('20140228184020');

INSERT INTO schema_migrations (version) VALUES ('20140403174920');

INSERT INTO schema_migrations (version) VALUES ('20140404182534');

INSERT INTO schema_migrations (version) VALUES ('20140406194649');

INSERT INTO schema_migrations (version) VALUES ('20140408184236');

INSERT INTO schema_migrations (version) VALUES ('20140409162847');

INSERT INTO schema_migrations (version) VALUES ('20140409191338');

INSERT INTO schema_migrations (version) VALUES ('20140416155148');

INSERT INTO schema_migrations (version) VALUES ('20140420181254');

INSERT INTO schema_migrations (version) VALUES ('20140422175449');

INSERT INTO schema_migrations (version) VALUES ('20140422190753');

INSERT INTO schema_migrations (version) VALUES ('20140427163152');

INSERT INTO schema_migrations (version) VALUES ('20140428171305');

INSERT INTO schema_migrations (version) VALUES ('20140801150459');

INSERT INTO schema_migrations (version) VALUES ('20140818204707');

INSERT INTO schema_migrations (version) VALUES ('20140818210819');

INSERT INTO schema_migrations (version) VALUES ('20140818212025');

INSERT INTO schema_migrations (version) VALUES ('20140818213205');

INSERT INTO schema_migrations (version) VALUES ('20140821064136');

INSERT INTO schema_migrations (version) VALUES ('20140821064951');
