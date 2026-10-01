SELECT
    order_id,
    product_name,
    quantity,
    unit_price,
    ROUND(quantity * unit_price, 2) AS gross_line_value
FROM 
    order_items
ORDER BY 
    gross_line_value DESC, line_id
LIMIT 
    15;

-- one row per order line, limited by top-15 with the biggest gross_line_value