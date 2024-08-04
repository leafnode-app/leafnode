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
    input bytea,
    input_hash bytea,
    expression bytea,
    expression_hash bytea,
    type bytea,
    type_hash bytea,
    value bytea,
    value_hash bytea,
    enabled boolean,
    node_id uuid NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.expressions OWNER TO postgres;

--
-- Name: extension_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.extension_tokens (
    id uuid NOT NULL,
    user_id bigint NOT NULL,
    token bytea NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL,
    token_hash bytea
);


ALTER TABLE public.extension_tokens OWNER TO postgres;

--
-- Name: input_processes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.input_processes (
    id uuid NOT NULL,
    node_id uuid NOT NULL,
    type bytea,
    type_hash bytea,
    value bytea,
    value_hash bytea,
    enabled boolean NOT NULL,
    async boolean NOT NULL,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.input_processes OWNER TO postgres;

--
-- Name: logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.logs (
    id uuid NOT NULL,
    node_id uuid NOT NULL,
    input bytea,
    result bytea,
    status boolean,
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
    should_log boolean DEFAULT true,
    expected_payload bytea,
    access_key bytea,
    access_key_hash bytea,
    integration_settings bytea,
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
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
-- Name: extension_tokens_id_user_id_token_hash_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX extension_tokens_id_user_id_token_hash_index ON public.extension_tokens USING btree (id, user_id, token_hash);


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

CREATE UNIQUE INDEX unique_user_extension ON public.extension_tokens USING btree (user_id, token_hash);


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
-- Name: extension_tokens extension_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.extension_tokens
    ADD CONSTRAINT extension_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


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

