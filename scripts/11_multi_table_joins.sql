-- Phase 3 - Lesson 11: Multi-Table Relational Joins
-- Purpose: Perform INNER, LEFT, and multi-table joins across users, orders, and products

-- 1. INNER JOIN: Retrieve users who have active orders
SELECT 
    u.user_id,
    u.full_name,
    o.order_id,
    o.total_amount,
    o.status
FROM users u
INNER JOIN orders o ON u.user_id = o.user_id;

-- 2. LEFT JOIN: Retrieve ALL users, including those who have never placed an order
SELECT 
    u.user_id,
    u.full_name,
    u.email,
    o.order_id,
    COALESCE(o.status, 'No Orders') AS order_status
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id;

-- 3. Multi-Table INNER JOIN: Connect orders to products through order_items
SELECT 
    o.order_id,
    u.full_name AS customer_name,
    p.name AS product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM orders o
JOIN users u ON o.user_id = u.user_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;