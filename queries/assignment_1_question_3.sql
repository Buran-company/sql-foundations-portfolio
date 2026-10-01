SELECT
    order_id,
    order_date,
    region,
    product_name,
    quantity,
    unit_price
FROM order_items
WHERE 
    category = 'Electronics'
    AND unit_price >= 100
    AND quantity >= 2
ORDER BY 
    unit_price DESC, order_id;

-- one row per order line matching the filter criteria