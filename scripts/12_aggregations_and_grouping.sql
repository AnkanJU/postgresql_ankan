-- Phase 3 - Lesson 12: Aggregations, GROUP BY, and HAVING
-- Purpose: Calculate total sales revenue, order counts, and filter aggregated results

-- 1. Global Aggregations: Summary stats across all orders
SELECT 
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS average_order_value,
    MIN(total_amount) AS smallest_order,
    MAX(total_amount) AS largest_order
FROM orders;

-- 2. GROUP BY: Aggregate order statistics per customer status
SELECT 
    u.user_id,
    u.full_name,
    COUNT(o.order_id) AS total_orders_placed,
    COALESCE(SUM(o.total_amount), 0.00) AS total_customer_spend
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id, u.full_name
ORDER BY total_customer_spend DESC;

-- 3. HAVING Clause: Filter groups to show only high-value categories/metrics
SELECT 
    c.category_name,
    COUNT(p.product_id) AS total_products,
    AVG(p.price) AS average_category_price
FROM categories c
JOIN products p ON c.category_id = p.category_id
GROUP BY c.category_name
HAVING AVG(p.price) > 50.00;