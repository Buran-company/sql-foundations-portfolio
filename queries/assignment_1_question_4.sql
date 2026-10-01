SELECT
    order_id,
    order_date,
    sales_channel,
    category,
    product_name
FROM 
    order_items
WHERE 
    sales_channel IN ('Online', 'Partner')
    AND order_date >= DATE '2026-01-01'
    AND order_date < DATE '2026-04-01'
ORDER BY 
    order_date, order_id;

-- one row per order line matching seles_channel and order_date (first quarter)