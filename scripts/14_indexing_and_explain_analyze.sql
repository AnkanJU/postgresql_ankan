-- Phase 4 - Lesson 14: Indexing Strategies & Query Optimization
-- Purpose: Create B-Tree and GIN indexes, then analyze performance using EXPLAIN ANALYZE

-- 1. Create a B-Tree index on high-frequency lookup column (products.sku)
CREATE INDEX IF NOT EXISTS idx_products_sku ON products(sku);

-- 2. Create a Composite B-Tree index for orders (filtering by user_id and status)
CREATE INDEX IF NOT EXISTS idx_orders_user_status ON orders(user_id, status);

-- 3. Create a GIN index on JSONB attributes column for fast document searches
CREATE INDEX IF NOT EXISTS idx_products_attributes_gin ON products USING gin(attributes);

-- 4. Analyze execution plan for standard B-Tree lookup
EXPLAIN ANALYZE
SELECT product_id, name, price 
FROM products 
WHERE sku = 'ELEC-LOGI-MX3';

-- 5. Analyze execution plan for JSONB key-value search using GIN index
EXPLAIN ANALYZE
SELECT name, price, attributes
FROM products
WHERE attributes @> '{"wireless": true}'::jsonb;-- Phase 4 - Lesson 14: Indexing Strategies & Query Optimization
-- Purpose: Create B-Tree and GIN indexes, then analyze performance using EXPLAIN ANALYZE

-- 1. Create a B-Tree index on high-frequency lookup column (products.sku)
CREATE INDEX IF NOT EXISTS idx_products_sku ON products(sku);

-- 2. Create a Composite B-Tree index for orders (filtering by user_id and status)
CREATE INDEX IF NOT EXISTS idx_orders_user_status ON orders(user_id, status);

-- 3. Create a GIN index on JSONB attributes column for fast document searches
CREATE INDEX IF NOT EXISTS idx_products_attributes_gin ON products USING gin(attributes);

-- 4. Analyze execution plan for standard B-Tree lookup
EXPLAIN ANALYZE
SELECT product_id, name, price 
FROM products 
WHERE sku = 'ELEC-LOGI-MX3';

-- 5. Analyze execution plan for JSONB key-value search using GIN index
EXPLAIN ANALYZE
SELECT name, price, attributes
FROM products
WHERE attributes @> '{"wireless": true}'::jsonb;