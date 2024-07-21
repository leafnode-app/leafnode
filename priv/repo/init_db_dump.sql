--
-- PostgreSQL database dump
--

-- Dumped from database version 15.6 (Debian 15.6-1.pgdg120+2)
-- Dumped by pg_dump version 15.6 (Debian 15.6-1.pgdg120+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: encrypted_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.encrypted_types (
    id bigint NOT NULL,
    encrypted_binary bytea,
    encrypted_string bytea,
    encrypted_map bytea,
    encrypted_integer bytea,
    encrypted_boolean bytea,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    encrypted_binary_hash bytea,
    encrypted_string_hash bytea,
    encrypted_map_hash bytea,
    encrypted_integer_hash bytea,
    encrypted_boolean_hash bytea
);


ALTER TABLE public.encrypted_types OWNER TO postgres;

--
-- Name: encrypted_types_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.encrypted_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.encrypted_types_id_seq OWNER TO postgres;

--
-- Name: encrypted_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.encrypted_types_id_seq OWNED BY public.encrypted_types.id;


--
-- Name: expressions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.expressions (
    id uuid NOT NULL,
    input character varying(255) DEFAULT ''::character varying,
    expression character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    value character varying(255) DEFAULT ''::character varying,
    node_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    enabled boolean DEFAULT true NOT NULL
);


ALTER TABLE public.expressions OWNER TO postgres;

--
-- Name: extension_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.extension_tokens (
    id uuid NOT NULL,
    user_id bigint NOT NULL,
    token character varying(255) NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.extension_tokens OWNER TO postgres;

--
-- Name: input_processes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.input_processes (
    id uuid NOT NULL,
    node_id uuid NOT NULL,
    type character varying(255) DEFAULT 'ai'::character varying,
    value text DEFAULT ''::character varying,
    enabled boolean NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    async boolean DEFAULT true NOT NULL
);


ALTER TABLE public.input_processes OWNER TO postgres;

--
-- Name: logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logs (
    id uuid NOT NULL,
    node_id uuid NOT NULL,
    input jsonb DEFAULT '{}'::jsonb,
    result jsonb DEFAULT '{}'::jsonb,
    status boolean NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.logs OWNER TO postgres;

--
-- Name: nodes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nodes (
    id uuid NOT NULL,
    user_id bigint NOT NULL,
    title character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    should_log boolean DEFAULT true,
    expected_payload jsonb DEFAULT '{}'::jsonb,
    access_key character varying(255),
    integration_settings jsonb DEFAULT '{}'::jsonb
);


ALTER TABLE public.nodes OWNER TO postgres;

--
-- Name: oauth_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.oauth_tokens (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    integration_type character varying(255) NOT NULL,
    access_token character varying(255) NOT NULL,
    refresh_token character varying(255),
    expires_at bigint,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.oauth_tokens OWNER TO postgres;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE public.schema_migrations OWNER TO postgres;

--
-- Name: user_oauth_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_oauth_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_oauth_tokens_id_seq OWNER TO postgres;

--
-- Name: user_oauth_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_oauth_tokens_id_seq OWNED BY public.oauth_tokens.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email public.citext NOT NULL,
    hashed_password character varying(255) NOT NULL,
    confirmed_at timestamp(0) without time zone,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: users_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_tokens (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    token bytea NOT NULL,
    context character varying(255) NOT NULL,
    sent_to character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.users_tokens OWNER TO postgres;

--
-- Name: users_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_tokens_id_seq OWNER TO postgres;

--
-- Name: users_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_tokens_id_seq OWNED BY public.users_tokens.id;


--
-- Name: encrypted_types id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.encrypted_types ALTER COLUMN id SET DEFAULT nextval('public.encrypted_types_id_seq'::regclass);


--
-- Name: oauth_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oauth_tokens ALTER COLUMN id SET DEFAULT nextval('public.user_oauth_tokens_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_tokens ALTER COLUMN id SET DEFAULT nextval('public.users_tokens_id_seq'::regclass);


--
-- Data for Name: encrypted_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.encrypted_types (id, encrypted_binary, encrypted_string, encrypted_map, encrypted_integer, encrypted_boolean, inserted_at, updated_at, encrypted_binary_hash, encrypted_string_hash, encrypted_map_hash, encrypted_integer_hash, encrypted_boolean_hash) FROM stdin;
\.


--
-- Data for Name: expressions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.expressions (id, input, expression, type, value, node_id, inserted_at, updated_at, enabled) FROM stdin;
\.


--
-- Data for Name: extension_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.extension_tokens (id, user_id, token, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: input_processes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.input_processes (id, node_id, type, value, enabled, inserted_at, updated_at, async) FROM stdin;
\.


--
-- Data for Name: logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.logs (id, node_id, input, result, status, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: nodes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nodes (id, user_id, title, description, enabled, inserted_at, updated_at, should_log, expected_payload, access_key, integration_settings) FROM stdin;
\.


--
-- Data for Name: oauth_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.oauth_tokens (id, user_id, integration_type, access_token, refresh_token, expires_at, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.schema_migrations (version, inserted_at) FROM stdin;
20240511145355	2024-07-21 21:58:55
20240511182349	2024-07-21 21:58:55
20240511211425	2024-07-21 21:58:55
20240511212151	2024-07-21 21:58:55
20240513205055	2024-07-21 21:58:55
20240527234142	2024-07-21 21:58:55
20240528230032	2024-07-21 21:58:55
20240531225910	2024-07-21 21:58:55
20240531231304	2024-07-21 21:58:55
20240602210928	2024-07-21 21:58:55
20240602214837	2024-07-21 21:58:55
20240630172918	2024-07-21 21:58:55
20240704230154	2024-07-21 21:58:55
20240706203819	2024-07-21 21:58:55
20240706222414	2024-07-21 21:58:55
20240707132306	2024-07-21 21:58:55
20240710102718	2024-07-21 21:58:55
20240710113840	2024-07-21 21:58:55
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, hashed_password, confirmed_at, inserted_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_tokens (id, user_id, token, context, sent_to, inserted_at) FROM stdin;
\.


--
-- Name: encrypted_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.encrypted_types_id_seq', 1, false);


--
-- Name: user_oauth_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_oauth_tokens_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


--
-- Name: users_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_tokens_id_seq', 1, false);


--
-- Name: encrypted_types encrypted_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.encrypted_types
    ADD CONSTRAINT encrypted_types_pkey PRIMARY KEY (id);


--
-- Name: expressions expressions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expressions
    ADD CONSTRAINT expressions_pkey PRIMARY KEY (id);


--
-- Name: extension_tokens extension_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.extension_tokens
    ADD CONSTRAINT extension_tokens_pkey PRIMARY KEY (id);


--
-- Name: input_processes input_processes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.input_processes
    ADD CONSTRAINT input_processes_pkey PRIMARY KEY (id);


--
-- Name: logs logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (id);


--
-- Name: nodes nodes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nodes
    ADD CONSTRAINT nodes_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: oauth_tokens user_oauth_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oauth_tokens
    ADD CONSTRAINT user_oauth_tokens_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users_tokens users_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_pkey PRIMARY KEY (id);


--
-- Name: extension_tokens_id_user_id_token_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX extension_tokens_id_user_id_token_index ON public.extension_tokens USING btree (id, user_id, token);


--
-- Name: input_processes_node_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX input_processes_node_id_index ON public.input_processes USING btree (node_id);


--
-- Name: logs_node_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX logs_node_id_index ON public.logs USING btree (node_id);


--
-- Name: nodes_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX nodes_user_id_index ON public.nodes USING btree (user_id);


--
-- Name: unique_node_expression; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_node_expression ON public.expressions USING btree (node_id);


--
-- Name: unique_node_input_process; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_node_input_process ON public.input_processes USING btree (node_id);


--
-- Name: unique_user_extension; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX unique_user_extension ON public.extension_tokens USING btree (user_id, token);


--
-- Name: user_oauth_tokens_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX user_oauth_tokens_user_id_index ON public.oauth_tokens USING btree (user_id);


--
-- Name: user_oauth_tokens_user_id_integration_type_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX user_oauth_tokens_user_id_integration_type_index ON public.oauth_tokens USING btree (user_id, integration_type);


--
-- Name: users_email_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email_index ON public.users USING btree (email);


--
-- Name: users_tokens_context_token_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_tokens_context_token_index ON public.users_tokens USING btree (context, token);


--
-- Name: users_tokens_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_tokens_user_id_index ON public.users_tokens USING btree (user_id);


--
-- Name: expressions expressions_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.expressions
    ADD CONSTRAINT expressions_node_id_fkey FOREIGN KEY (node_id) REFERENCES public.nodes(id) ON DELETE CASCADE;


--
-- Name: extension_tokens extension_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.extension_tokens
    ADD CONSTRAINT extension_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: input_processes input_processes_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.input_processes
    ADD CONSTRAINT input_processes_node_id_fkey FOREIGN KEY (node_id) REFERENCES public.nodes(id) ON DELETE CASCADE;


--
-- Name: logs logs_node_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.logs
    ADD CONSTRAINT logs_node_id_fkey FOREIGN KEY (node_id) REFERENCES public.nodes(id) ON DELETE CASCADE;


--
-- Name: nodes nodes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nodes
    ADD CONSTRAINT nodes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: oauth_tokens user_oauth_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.oauth_tokens
    ADD CONSTRAINT user_oauth_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users_tokens users_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_tokens
    ADD CONSTRAINT users_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

