DROP SCHEMA IF EXISTS public CASCADE;

CREATE SCHEMA public;

CREATE TABLE IF NOT EXISTS clients (
	id SERIAL PRIMARY KEY,
	name VARCHAR(32) NOT NULL,
	lastname VARCHAR(32) NOT NULL,
	email VARCHAR(32) NOT NULL UNIQUE,
	phone VARCHAR(32) NOT NULL,
	date_register TIMESTAMP(6) NOT NULL
);

CREATE TABLE IF NOT EXISTS products (
	id SERIAL PRIMARY KEY,
	price DECIMAL NOT NULL,
	quantity INTEGER NOT NULL
);

CREATE TYPE enum_status AS ENUM (
	'Pendiente',
	'Enviado',
	'Entregado'
);

CREATE TABLE IF NOT EXISTS orders (
	id SERIAL PRIMARY KEY,
	client_id INTEGER NOT NULL,
	date_order TIMESTAMP(6),
	status enum_status,
	
	CONSTRAINT fk_client_id FOREIGN KEY(client_id) REFERENCES clients(id)
);

CREATE TABLE IF NOT EXISTS orders_details (
	id SERIAL PRIMARY KEY,
	order_id INTEGER NOT NULL,
	product_id INTEGER NOT NULL,
	quantity INTEGER NOT NULL,
	
	CONSTRAINT fk_order_id FOREIGN KEY(order_id) REFERENCES orders(id),
	CONSTRAINT fk_product_id FOREIGN KEY(product_id) REFERENCES products(id)
);

CREATE TYPE payments_method AS ENUM (
	'PayPal'
);

CREATE TABLE IF NOT EXISTS payments (
	id SERIAL NOT NULL,
	order_details_id INTEGER NOT NULL,
	date_payment TIMESTAMP(6) NOT NULL,
	total DECIMAL NOT NULL,
	payment payments_method
);