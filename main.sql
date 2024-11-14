DO $$
	BEGIN
		CALL insert_clients();
		CALL insert_products();
		CALL insert_orders();
		CALL insert_orders_details();
		CALL insert_payments();
	END;
$$;

SELECT * FROM view_data;