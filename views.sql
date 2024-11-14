DROP VIEW IF EXISTS view_data;

CREATE OR REPLACE VIEW view_data AS SELECT 
	CONCAT(c.name, ' ', c.lastname) AS full_name,
	COUNT(o.client_id) AS orders,
	MIN(o.date_order::timestamp(0)) AS first_order_date,
	(get_days_transcurred(MIN(o.date_order))) AS first_order_at,
	MAX(o.date_order::timestamp(0)) AS last_order_date,
	(get_days_transcurred(MAX(o.date_order))) AS last_order_at,
	(get_days_estimate(c.id)) AS estimate_day_per_order,
	SUM(p.price) AS total_cost,
	CONCAT
	(
		(get_discount(SUM(p.price), COUNT(o.client_id)::integer))::text,
		' ',
		'(-', (FLOOR(get_percent(COUNT(o.client_id)::integer) * 100)), '% OFF)'
	) AS final_cost
FROM payments AS ps
FULL JOIN orders_details AS od
ON od.id = ps.order_details_id
INNER JOIN orders AS o
ON o.id = od.order_id
LEFT JOIN clients AS c
ON c.id = o.client_id
LEFT JOIN products AS P
ON p.id = od.product_id
GROUP BY 
	c.id,
	c.name,
	c.lastname,
	c.phone
ORDER BY orders DESC;
	
SELECT * FROM view_data;
	