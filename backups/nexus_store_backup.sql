--
-- PostgreSQL database dump
--

\restrict 9oEKpVp7mzgVv6bfAZvck63ifN1wpGQvjioEAxMYeB7VWozZwuR7Dm3hG5APNBD

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: order_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.order_status_enum AS ENUM (
    'pending',
    'processing',
    'shipped',
    'delivered',
    'cancelled'
);


ALTER TYPE public.order_status_enum OWNER TO postgres;

--
-- Name: fn_calculate_order_total(numeric, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_calculate_order_total(p_subtotal numeric, p_tax_rate numeric DEFAULT 0.080) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN ROUND(p_subtotal + (p_subtotal * p_tax_rate), 2);
END;
$$;


ALTER FUNCTION public.fn_calculate_order_total(p_subtotal numeric, p_tax_rate numeric) OWNER TO postgres;

--
-- Name: fn_log_inventory_change(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.fn_log_inventory_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Only log when stock quantity actually changes
    IF OLD.stock_quantity <> NEW.stock_quantity THEN
        INSERT INTO inventory_audit_log (product_id, old_stock, new_stock)
        VALUES (NEW.product_id, OLD.stock_quantity, NEW.stock_quantity);
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.fn_log_inventory_change() OWNER TO postgres;

--
-- Name: sp_deduct_inventory(bigint, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.sp_deduct_inventory(IN p_product_id bigint, IN p_quantity_deducted integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_current_stock INT;
BEGIN
    -- Fetch current stock level
    SELECT stock_quantity INTO v_current_stock
    FROM products
    WHERE product_id = p_product_id;

    IF v_current_stock IS NULL THEN
        RAISE EXCEPTION 'Product ID % does not exist', p_product_id;
    END IF;

    IF v_current_stock < p_quantity_deducted THEN
        RAISE EXCEPTION 'Insufficient inventory. Available: %, Requested: %', v_current_stock, p_quantity_deducted;
    END IF;

    -- Deduct inventory
    UPDATE products
    SET stock_quantity = stock_quantity - p_quantity_deducted
    WHERE product_id = p_product_id;

    RAISE NOTICE 'Inventory updated successfully for product %', p_product_id;
END;
$$;


ALTER PROCEDURE public.sp_deduct_inventory(IN p_product_id bigint, IN p_quantity_deducted integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categories (
    category_id bigint NOT NULL,
    category_name character varying(100) NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.categories OWNER TO postgres;

--
-- Name: categories_category_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categories_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categories_category_id_seq OWNER TO postgres;

--
-- Name: categories_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categories_category_id_seq OWNED BY public.categories.category_id;


--
-- Name: inventory_audit_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory_audit_log (
    audit_id bigint NOT NULL,
    product_id bigint NOT NULL,
    old_stock integer NOT NULL,
    new_stock integer NOT NULL,
    changed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.inventory_audit_log OWNER TO postgres;

--
-- Name: inventory_audit_log_audit_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.inventory_audit_log_audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.inventory_audit_log_audit_id_seq OWNER TO postgres;

--
-- Name: inventory_audit_log_audit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.inventory_audit_log_audit_id_seq OWNED BY public.inventory_audit_log.audit_id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    order_id bigint NOT NULL,
    user_id bigint NOT NULL,
    total_amount numeric(10,2) NOT NULL,
    status character varying(50) DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT orders_total_amount_check CHECK ((total_amount >= (0)::numeric))
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: mv_daily_sales_summary; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_daily_sales_summary AS
 SELECT date(created_at) AS sales_date,
    count(order_id) AS total_orders,
    sum(total_amount) AS total_revenue,
    avg(total_amount) AS average_order_value
   FROM public.orders o
  WHERE ((status)::text = 'completed'::text)
  GROUP BY (date(created_at))
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_daily_sales_summary OWNER TO postgres;

--
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    order_item_id bigint NOT NULL,
    order_id bigint NOT NULL,
    product_id bigint NOT NULL,
    quantity integer NOT NULL,
    unit_price numeric(10,2) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT order_items_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT order_items_unit_price_check CHECK ((unit_price >= (0)::numeric))
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_order_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_order_item_id_seq OWNER TO postgres;

--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_order_item_id_seq OWNED BY public.order_items.order_item_id;


--
-- Name: orders_order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.orders_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_order_id_seq OWNER TO postgres;

--
-- Name: orders_order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.orders_order_id_seq OWNED BY public.orders.order_id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    product_id bigint NOT NULL,
    category_id bigint NOT NULL,
    sku character varying(50) NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    price numeric(10,2) NOT NULL,
    stock_quantity integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    product_guid uuid DEFAULT gen_random_uuid(),
    attributes jsonb DEFAULT '{}'::jsonb,
    CONSTRAINT products_price_check CHECK ((price > (0)::numeric)),
    CONSTRAINT products_stock_quantity_check CHECK ((stock_quantity >= 0))
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: products_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.products_product_id_seq OWNER TO postgres;

--
-- Name: products_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_product_id_seq OWNED BY public.products.product_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id bigint NOT NULL,
    full_name character varying(100) NOT NULL,
    email character varying(255) NOT NULL,
    password_hash text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: view_customer_orders; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.view_customer_orders AS
 SELECT u.user_id,
    u.full_name,
    u.email,
    o.order_id,
    o.total_amount,
    o.status AS order_status,
    o.created_at AS order_date
   FROM (public.users u
     JOIN public.orders o ON ((u.user_id = o.user_id)))
  WHERE (u.is_active = true);


ALTER VIEW public.view_customer_orders OWNER TO postgres;

--
-- Name: categories category_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories ALTER COLUMN category_id SET DEFAULT nextval('public.categories_category_id_seq'::regclass);


--
-- Name: inventory_audit_log audit_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_audit_log ALTER COLUMN audit_id SET DEFAULT nextval('public.inventory_audit_log_audit_id_seq'::regclass);


--
-- Name: order_items order_item_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN order_item_id SET DEFAULT nextval('public.order_items_order_item_id_seq'::regclass);


--
-- Name: orders order_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders ALTER COLUMN order_id SET DEFAULT nextval('public.orders_order_id_seq'::regclass);


--
-- Name: products product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products ALTER COLUMN product_id SET DEFAULT nextval('public.products_product_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categories (category_id, category_name, description, created_at) FROM stdin;
1	Electronics	Gadgets, devices, and accessories	2026-09-10 20:28:34.442318+05:30
2	Apparel	Clothing and wearable gear	2026-09-10 20:28:34.442318+05:30
\.


--
-- Data for Name: inventory_audit_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventory_audit_log (audit_id, product_id, old_stock, new_stock, changed_at) FROM stdin;
1	1	50	45	2026-09-10 20:38:42.49246+05:30
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (order_item_id, order_id, product_id, quantity, unit_price, created_at) FROM stdin;
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (order_id, user_id, total_amount, status, created_at) FROM stdin;
1	1	1499.99	completed	2026-09-10 20:22:02.176051+05:30
2	1	299.50	processing	2026-09-10 20:22:02.176051+05:30
3	1	89.99	completed	2026-09-10 20:24:44.097777+05:30
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (product_id, category_id, sku, name, description, price, stock_quantity, is_active, created_at, product_guid, attributes) FROM stdin;
3	2	APPR-HOOD-BLK	Nexus Store Hoodie (Black)	100% Cotton Heavyweight Hoodie	49.00	100	t	2026-09-10 20:28:34.513369+05:30	2463e167-0b72-4039-940f-b32df88dc780	{}
2	1	ELEC-KEYCH-K2	Keychron K2 V2	Wireless Mechanical Keyboard	79.50	30	t	2026-09-10 20:28:34.513369+05:30	de0bfd9f-ad1a-4dc4-acb7-83719cbaa160	{"brand": "Keychron", "switches": "Gateron Brown", "backlight": "RGB"}
1	1	ELEC-LOGI-MX3	Logitech MX Master 3S	Wireless Ergonomic Mouse	99.99	45	t	2026-09-10 20:28:34.513369+05:30	e2209dcb-1a59-4600-8a44-6d507822f1bb	{"dpi": 8000, "brand": "Logitech", "wireless": true}
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, full_name, email, password_hash, is_active, created_at) FROM stdin;
3	Jane Smith	jane.smith@example.com	hashed_pass_789	t	2026-09-10 20:19:11.765461+05:30
1	Ankan Roy	ankan.roy@nexusstore.com	hashed_pass_123	t	2026-09-10 20:19:11.765461+05:30
5	Dwight Schrute	dwight@dundermifflin.com	hashed_pass_888	t	2026-09-10 20:20:46.183249+05:30
6	Jim Halpert	jim@dundermifflin.com	hashed_pass_777	t	2026-09-10 20:20:46.183249+05:30
4	Michael Scott	michael@dundermifflin.com	hashed_pass_999	f	2026-09-10 20:20:46.119774+05:30
\.


--
-- Name: categories_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categories_category_id_seq', 2, true);


--
-- Name: inventory_audit_log_audit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.inventory_audit_log_audit_id_seq', 1, true);


--
-- Name: order_items_order_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_order_item_id_seq', 1, false);


--
-- Name: orders_order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_order_id_seq', 4, true);


--
-- Name: products_product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_product_id_seq', 5, true);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 6, true);


--
-- Name: categories categories_category_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_category_name_key UNIQUE (category_name);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);


--
-- Name: inventory_audit_log inventory_audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_audit_log
    ADD CONSTRAINT inventory_audit_log_pkey PRIMARY KEY (audit_id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_item_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (product_id);


--
-- Name: products products_sku_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_sku_key UNIQUE (sku);


--
-- Name: order_items unique_order_product; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT unique_order_product UNIQUE (order_id, product_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: idx_mv_daily_sales_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_mv_daily_sales_date ON public.mv_daily_sales_summary USING btree (sales_date);


--
-- Name: idx_orders_user_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_orders_user_status ON public.orders USING btree (user_id, status);


--
-- Name: idx_products_attributes_gin; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_attributes_gin ON public.products USING gin (attributes);


--
-- Name: idx_products_sku; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_sku ON public.products USING btree (sku);


--
-- Name: products trg_audit_product_stock; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_audit_product_stock AFTER UPDATE OF stock_quantity ON public.products FOR EACH ROW EXECUTE FUNCTION public.fn_log_inventory_change();


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON DELETE CASCADE;


--
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(product_id) ON DELETE RESTRICT;


--
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id) ON DELETE RESTRICT;


--
-- Name: products products_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(category_id) ON DELETE RESTRICT;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO nexus_app_user;


--
-- Name: TABLE categories; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.categories TO nexus_app_user;


--
-- Name: SEQUENCE categories_category_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.categories_category_id_seq TO nexus_app_user;


--
-- Name: TABLE inventory_audit_log; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.inventory_audit_log TO nexus_app_user;


--
-- Name: SEQUENCE inventory_audit_log_audit_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.inventory_audit_log_audit_id_seq TO nexus_app_user;


--
-- Name: TABLE orders; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.orders TO nexus_app_user;


--
-- Name: TABLE mv_daily_sales_summary; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.mv_daily_sales_summary TO nexus_app_user;


--
-- Name: TABLE order_items; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.order_items TO nexus_app_user;


--
-- Name: SEQUENCE order_items_order_item_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.order_items_order_item_id_seq TO nexus_app_user;


--
-- Name: SEQUENCE orders_order_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.orders_order_id_seq TO nexus_app_user;


--
-- Name: TABLE products; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.products TO nexus_app_user;


--
-- Name: SEQUENCE products_product_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.products_product_id_seq TO nexus_app_user;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.users TO nexus_app_user;


--
-- Name: SEQUENCE users_user_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.users_user_id_seq TO nexus_app_user;


--
-- Name: TABLE view_customer_orders; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,UPDATE ON TABLE public.view_customer_orders TO nexus_app_user;


--
-- Name: mv_daily_sales_summary; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mv_daily_sales_summary;


--
-- PostgreSQL database dump complete
--

\unrestrict 9oEKpVp7mzgVv6bfAZvck63ifN1wpGQvjioEAxMYeB7VWozZwuR7Dm3hG5APNBD

