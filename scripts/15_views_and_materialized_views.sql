-- Phase 4 - Lesson 15: Virtual and Materialized Views
-- Purpose: Simplify query reporting and pre-compute complex financial metrics

-- 1. Create a Standard View to hide sensitive user data and join active orders
CREATE OR REPLACE VIEW view_customer_orders AS
SELECT 
    u.user_id,
    u.full_name,
    u.email,
    o.order_id,
    o.total_amount,
    o.status AS order_status,
    o.created_at AS order_date
FROM users u
JOIN orders o ON u.user_id = o.user_id
WHERE u.is_active = TRUE;

-- Query the standard view directly
SELECT * FROM view_customer_orders WHERE order_status = 'completed';


-- 2. Create a Materialized View for heavy revenue analytics
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_daily_sales_summary AS
SELECT 
    DATE(o.created_at) AS sales_date,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_revenue,
    AVG(o.total_amount) AS average_order_value
FROM orders o
WHERE o.status = 'completed'
GROUP BY DATE(o.created_at);

-- Create a unique index on the materialized view to enable CONCURRENT refreshes
CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_daily_sales_date ON mv_daily_sales_summary(sales_date);

-- Query the materialized snapshot
SELECT * FROM mv_daily_sales_summary;

-- 3. Command to manually update materialized data
REFRESH MATERIALIZED VIEW CONCURRENTLY mv_daily_sales_summary;