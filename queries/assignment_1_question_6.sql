SELECT
    line_id,
    product_name,
    UPPER(TRIM(product_name)) AS normalized_label
FROM 
    order_items
WHERE 
    UPPER(TRIM(product_name)) LIKE 'S%'
ORDER BY 
    normalized_label, line_id;

-- one row per order line, where the product_name after clean up from spaces is beginning with 'S'