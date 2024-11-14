CREATE OR REPLACE FUNCTION get_clients(refcursor) RETURNS refcursor AS $$
	DECLARE
		result RECORD;
	BEGIN
		OPEN $1 FOR SELECT * FROM json_populate_recordset(null::clients, '
			[
			  {
				"name": "Juan",
				"lastname": "Pérez",
				"email": "juan.perez@email.com",
				"phone": "+54 9 11 2345-6789"
			  },
			  {
				"name": "Ana",
				"lastname": "Gómez",
				"email": "ana.gomez@email.com",
				"phone": "+54 9 11 9876-5432"
			  },
			  {
				"name": "Carlos",
				"lastname": "Lopez",
				"email": "carlos.lopez@email.com",
				"phone": "+54 9 11 4567-1234"
			  },
			  {
				"name": "Lucía",
				"lastname": "Martínez",
				"email": "lucia.martinez@email.com",
				"phone": "+54 9 11 6789-4321"
			  },
			  {
				"name": "Federico",
				"lastname": "Rodríguez",
				"email": "federico.rodriguez@email.com",
				"phone": "+54 9 11 3456-7890"
			  },
			  {
				"name": "Mariana",
				"lastname": "Fernández",
				"email": "mariana.fernandez@email.com",
				"phone": "+54 9 11 6543-2109"
			  },
			  {
				"name": "Martín",
				"lastname": "Sánchez",
				"email": "martin.sanchez@email.com",
				"phone": "+54 9 11 5678-3456"
			  },
			  {
				"name": "Valentina",
				"lastname": "Suárez",
				"email": "valentina.suarez@email.com",
				"phone": "+54 9 11 2345-9876"
			  },
			  {
				"name": "Diego",
				"lastname": "Romero",
				"email": "diego.romero@email.com",
				"phone": "+54 9 11 8765-4321"
			  },
			  {
				"name": "Camila",
				"lastname": "Álvarez",
				"email": "camila.alvarez@email.com",
				"phone": "+54 9 11 1234-5678"
			  }
			]'
		);
			RETURN $1;
		CLOSE $1;
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_random_date() RETURNS timestamp AS $$
	DECLARE
		min_day INTEGER := 30;
		max_day INTEGER := 365;
	BEGIN
		RETURN NOW() - (RANDOM() * (max_day - min_day) + min_day || 'd')::INTERVAL;
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_random_price() RETURNS decimal AS $$
	DECLARE
		min_value DECIMAL := 10.00;
		max_value DECIMAL := 1000.00;
		result DECIMAL;
	BEGIN
		result := RANDOM() * (max_value - min_value) + min_value;
		return ROUND(result, 2);
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_random_client() RETURNS SETOF clients AS $$
	BEGIN
		RETURN 
			QUERY
				SELECT * 
				FROM clients 
				ORDER BY RANDOM() 
				LIMIT 1;
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_random_order() RETURNS SETOF orders AS $$
	BEGIN
		RETURN 
			QUERY 
				SELECT * 
				FROM orders 
				ORDER BY RANDOM() 
				LIMIT 1;
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_random_product() RETURNS SETOF products AS $$
	DECLARE
	BEGIN
		RETURN 
			QUERY 
				SELECT * 
				FROM products 
				ORDER BY RANDOM() 
				LIMIT 1;
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_random_orders_details() RETURNS SETOF orders_details AS $$
	BEGIN
		RETURN 
			QUERY 
				SELECT * 
				FROM orders_details 
				ORDER BY RANDOM() 
				LIMIT 1;
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_product_stock(product_quantity integer, product_id integer) RETURNS SETOF products AS $$
	BEGIN
		UPDATE products SET quantity = quantity - product_quantity WHERE id = product_id;
		RETURN 
			QUERY
				SELECT * 
				FROM products 
				WHERE id = product_id;
				
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_percent(integer) RETURNS decimal AS $$
	DECLARE
		percent DECIMAL;
	BEGIN
		IF $1 IS NULL THEN
			RETURN 0;
		END IF;
		
		CASE
			WHEN $1 >= 90 THEN
				percent := 0.60;
			WHEN $1 >= 80 THEN
				percent := 0.40;
			WHEN $1 >= 60 THEN
				percent := 0.20;
			WHEN $1 >= 40 THEN
				percent := 0.10;
			ELSE
				percent := 0.05;
		END CASE;
		
		RETURN percent;
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_discount(price decimal, quantity integer) RETURNS decimal AS $$
	BEGIN
		IF price IS NULL OR quantity IS NULL THEN
			RAISE EXCEPTION 'Parameter is empty';
		END IF;
		
		RETURN ROUND(price - (price * get_percent(quantity)), 2);
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_days_transcurred(timestamp) RETURNS text AS $$
	DECLARE
		get_timestamp INTEGER;
	BEGIN
		RETURN ((NOW())::timestamp(0) - ($1)::timestamp(0));
		
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_days_estimate(integer) RETURNS interval AS $$
	DECLARE
		result INTERVAL;
	BEGIN
		RETURN (SELECT 
			date_order - COALESCE(LAG(date_order) OVER (ORDER BY date_order ASC), date_order) AS day_estimate
		FROM orders
		WHERE client_id = $1
		ORDER BY day_estimate DESC
		LIMIT 1
		)::interval;
	END;
$$ LANGUAGE plpgsql;