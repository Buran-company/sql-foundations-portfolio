SELECT
    COUNT(*) AS total_rows,
    COUNT(region) AS rows_with_region,
    COUNT(*) - COUNT(region) AS rows_missing_region,
    COUNT(discount_pct) AS rows_with_discount,
    COUNT(*) - COUNT(discount_pct) AS rows_missing_discount
FROM 
    order_items;

-- one row per dataset