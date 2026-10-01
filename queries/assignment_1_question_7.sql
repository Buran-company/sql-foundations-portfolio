SELECT
    order_id,
    order_date,
    EXTRACT(YEAR FROM order_date)::INTEGER AS order_year,
    EXTRACT(MONTH FROM order_date)::INTEGER AS order_month
FROM 
    order_items
WHERE 
    order_date >= DATE '2026-01-01'
    AND order_date < DATE '2027-01-01'
ORDER BY 
    order_date, order_id, line_id;

-- one row per order line, created in 2026