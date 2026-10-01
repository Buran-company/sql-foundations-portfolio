SELECT
    order_id,
    order_date,
    product_name,
    COALESCE(shipped_date::text, 'Not shipped') AS shipment_status
FROM 
    order_items
WHERE 
    shipped_date IS NULL
ORDER BY 
    order_date, order_id, line_id;

-- one row per 'Not shipped' position