-- Phase 3 - Lesson 13: Subqueries, CTEs, and Window Functions
-- Purpose: Perform complex analytics using nested queries, WITH clauses, and window functions

-- 1. Subquery: Find products priced above the store average
SELECT product_id, sku, name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- 2. CTE (Common Table Expression): Calculate customer lifetime spend and filter top spenders
WITH customer_spending AS (
    SELECT 
        u.user_id,
        u.full_name,
        u.email,
        COUNT(o.order_id) AS total_orders,
        COALESCE(SUM(o.total_amount), 0.00) AS total_spent
    FROM users u
    LEFT JOIN orders o ON u.user_id = o.user_id
    GROUP BY u.user_id, u.full_name, u.email
)
SELECT user_id, full_name, email, total_orders, total_spent
FROM customer_spending
WHERE total_spent > 100.00;

-- 3. Window Function: Rank products by price within their category
SELECT 
    p.product_id,
    c.category_name,
    p.name AS product_name,
    p.price,
    ROW_NUMBER() OVER(PARTITION BY p.category_id ORDER BY p.price DESC) AS price_rank_in_category,
    SUM(p.price) OVER(PARTITION BY p.category_id) AS total_category_inventory_value
FROM products p
JOIN categories c ON p.category_id = c.category_id;-- Phase 3 - Lesson 13: Subqueries, CTEs, and Window Functions
-- Purpose: Perform complex analytics using nested queries, WITH clauses, and window functions

-- 1. Subquery: Find products priced above the store average
SELECT product_id, sku, name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);

-- 2. CTE (Common Table Expression): Calculate customer lifetime spend and filter top spenders
WITH customer_spending AS (
    SELECT 
        u.user_id,
        u.full_name,
        u.email,
        COUNT(o.order_id) AS total_orders,
        COALESCE(SUM(o.total_amount), 0.00) AS total_spent
    FROM users u
    LEFT JOIN orders o ON u.user_id = o.user_id
    GROUP BY u.user_id, u.full_name, u.email
)
SELECT user_id, full_name, email, total_orders, total_spent
FROM customer_spending
WHERE total_spent > 100.00;

-- 3. Window Function: Rank products by price within their category
SELECT 
    p.product_id,
    c.category_name,
    p.name AS product_name,
    p.price,
    ROW_NUMBER() OVER(PARTITION BY p.category_id ORDER BY p.price DESC) AS price_rank_in_category,
    SUM(p.price) OVER(PARTITION BY p.category_id) AS total_category_inventory_value
FROM products p
JOIN categories c ON p.category_id = c.category_id;