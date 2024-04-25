select
	p.id as product_id,
	p.name as product_name,
	count(status) as number_of_times_in_successful_orders
from
	alt_school.products p
join
	alt_school.line_items li on p.id = li.item_id 
join 
	alt_school.orders o on li.order_id = o.order_id 
where 
	status = 'success'
group by 
	product_id, product_name
order by 
	number_of_times_in_successful_orders desc
limit 1;


select
	c.customer_id,
    c.location,
    SUM(p.price) AS total_spend
FROM
    alt_school.events e
JOIN
   	alt_school.products p ON p.id = (e.event_data->>'item_id')::int
JOIN
    alt_school.customers c ON e.customer_id::uuid = c.customer_id
JOIN
    alt_school.orders o ON o.customer_id::uuid = c.customer_id
WHERE
    o.status = 'success'
GROUP BY
   c.customer_id ,c.location
ORDER BY
    total_spend DESC
LIMIT 5;


select 
	c.location as location,
	count(*) as checkout_count
from
	alt_school.customers c 
join
	alt_school.events e on c.customer_id = e.customer_id
where
	e.event_data->> 'status' = 'success'
group by 
	c."location"
order by 
	checkout_count desc
limit 1;


WITH AbandonedCarts AS (
    SELECT 
        customer_id,
        MIN(event_timestamp) AS abandonment_time
    FROM 
        alt_school.events
    WHERE 
        event_data->>'event_type' = 'remove_from_cart'
    GROUP BY 
        customer_id
)
SELECT 
    e.customer_id,
    COUNT(*) AS num_events
FROM 
    alt_school.events e
JOIN 
    AbandonedCarts ac ON e.customer_id = ac.customer_id
WHERE 
    e.event_timestamp < ac.abandonment_time
    AND e.event_data->>'event_type' != 'visit'
GROUP BY 
    e.customer_id;


SELECT 
    AVG(total_visits)::numeric(10, 2) AS average_visits
FROM (
    SELECT 
        c.customer_id,
        COUNT(e.event_data) AS total_visits
    FROM 
        alt_school.customers c
    JOIN 
        alt_school.events e ON c.customer_id = e.customer_id
    JOIN 
        alt_school.orders o ON c.customer_id = o.customer_id
    WHERE 
        e.event_data->>'event_type' = 'visit'
        AND o.status = 'success'
    GROUP BY 
        c.customer_id
) AS subquery;
