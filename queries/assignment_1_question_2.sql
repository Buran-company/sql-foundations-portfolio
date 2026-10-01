SELECT DISTINCT
    region,
    sales_channel
FROM 
    order_items
WHERE 
    region IS NOT NULL
    AND sales_channel IS NOT NULL
ORDER BY 
    region, sales_channel;

-- one row per unique combination of region and sales_channel