CREATE OR REPLACE FUNCTION update_product_stock() RETURNS trigger AS $$
	DECLARE
		result_od ORDERS_DETAILS; 
		result_quantity INTEGER;
	BEGIN
		SELECT * FROM orders_details
		WHERE id = new.order_details_id
		INTO result_od;
		
		SELECT quantity
		FROM products
		WHERE id = result_od.product_id
		INTO result_quantity;
		
		IF result_quantity < result_od.quantity THEN
			RAISE NOTICE 'Stock is insufficient in product #%.', result_od.product_id;
			RETURN null;
		END IF;
		
		UPDATE products 
		SET quantity = quantity - result_od.quantity 
		WHERE id = result_od.product_id;
		RETURN new;
	END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_update_stock 
BEFORE INSERT ON payments
FOR EACH ROW
EXECUTE FUNCTION update_product_stock();