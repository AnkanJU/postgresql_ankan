-- Phase 1 - Lesson 6: Relational Tables and Foreign Keys
-- Purpose: Create orders table with a foreign key constraint linking to users

-- 1. Create the child table (orders) referencing the parent table (users)
CREATE TABLE IF NOT EXISTS orders (
    order_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    total_amount NUMERIC(10, 2) NOT NULL CHECK (total_amount >= 0),
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. INSERT valid orders linked to active user_id 1 (Ankan Roy)
INSERT INTO orders (user_id, total_amount, status)
VALUES 
    (1, 1499.99, 'completed'),
    (1, 299.50, 'processing')
RETURNING order_id, user_id, total_amount, status;

-- 3. SELECT query joining users and orders
SELECT 
    o.order_id,
    u.full_name,
    u.email,
    o.total_amount,
    o.status
FROM orders o
JOIN users u ON o.user_id = u.user_id;