CREATE OR REPLACE PROCEDURE insert_clients() AS $$
	DECLARE
		ref_cursor REFCURSOR;
		result CLIENTS;
	BEGIN 
		SELECT * FROM get_clients('cur_clients') INTO ref_cursor;
		
		LOOP
			FETCH ref_cursor INTO result;
			
			IF NOT FOUND THEN
				EXIT;
			END IF;
			
			INSERT INTO clients (name, lastname, email, phone, date_register) 
			VALUES (result.name, result.lastname, result.email, result.phone, get_random_date());
		END LOOP;
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE insert_products() AS $$
	DECLARE
		rnd_quantity INTEGER;
	BEGIN
		FOR i IN 1..100 LOOP
			rnd_quantity := (RANDOM() * 1000) + 1;
			INSERT INTO products (price, quantity) VALUES ((SELECT get_random_price()), rnd_quantity);
		END LOOP;
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE insert_orders() AS $$
	DECLARE
		cur_clients CURSOR FOR SELECT COUNT(id) FROM clients; 
		rnd_status_arr TEXT[] := '{Pendiente, Entregado, Enviado}'::TEXT[];
		rnd_status ENUM_STATUS;
		rnd_client_id INTEGER;
	BEGIN
		FOR i IN 1..750 LOOP
			rnd_status := rnd_status_arr[FLOOR(RANDOM() * array_length(rnd_status_arr, 1)) + 1];
			
			SELECT id FROM get_random_client() INTO rnd_client_id;
			
			INSERT INTO orders (client_id, date_order, status) 
			VALUES 
				(rnd_client_id, get_random_date(), rnd_status);
		END LOOP;
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE insert_orders_details() AS $$ 
	DECLARE
		rnd_order_id INTEGER;
		rnd_product_id INTEGER;
		rnd_quantity INTEGER;
		products_min INTEGER := 5;
		products_max INTEGER := 20;
	BEGIN
		FOR i IN 1..100 LOOP
			SELECT id FROM get_random_order() INTO rnd_order_id;
			SELECT id FROM get_random_product() INTO rnd_product_id;
			rnd_quantity := RANDOM() * (products_max - products_min) + products_min;

			INSERT INTO orders_details (order_id, product_id, quantity) VALUES (rnd_order_id, rnd_product_id, rnd_quantity);
		END LOOP;
	END;	
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE insert_payments() AS $$
	DECLARE
		cur_orders_details CURSOR FOR
			SELECT * FROM get_random_orders_details();
	DECLARE
		orders_details_result ORDERS_DETAILS;
		orders_result ORDERS;
		products_result PRODUCTS;
		date_order TIMESTAMP(6);		
	BEGIN
		FOR i IN 1..250 LOOP
			OPEN cur_orders_details;
				FETCH cur_orders_details INTO orders_details_result;
				
				SELECT * 
				FROM orders 
				WHERE id = orders_details_result.order_id
				INTO orders_result;
				
				SELECT * 
				FROM products
				WHERE id = orders_details_result.product_id
				INTO products_result;
				
				date_order := orders_result.date_order + (RANDOM() * 90 || 'd')::INTERVAL;
				
				INSERT INTO payments 
				(order_details_id, date_payment, total, payment)
			VALUES
				(orders_details_result.id, date_order::timestamp(0), (SELECT SUM(products_result.price)), 'PayPal');
			CLOSE cur_orders_details;
		END LOOP;
	END;
$$ LANGUAGE plpgsql;
