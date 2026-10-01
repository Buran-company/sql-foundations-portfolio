SELECT
    COUNT(*) AS total_order_lines,
    COUNT(DISTINCT order_id) AS total_distinct_orders,
    SUM(quantity) AS total_units_sold,
    ROUND(AVG(unit_price), 2) AS avg_unit_price,
    ROUND(MIN(unit_price), 2) AS min_unit_price,
    ROUND(MAX(unit_price), 2) AS max_unit_price,
    ROUND(SUM(quantity * unit_price), 2) AS total_gross_revenue
FROM 
    order_items;

-- one row per dataset