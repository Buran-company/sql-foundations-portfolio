SELECT
    line_id,
    order_id,
    order_date,
    product_name AS product,
    quantity,
    unit_price AS price_per_unit
FROM 
    order_items
ORDER BY 
    line_id
LIMIT 
    20;

-- one row per order line