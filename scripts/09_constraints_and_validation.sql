-- Phase 2 - Lesson 9: Advanced Constraints & Validation Tests
-- Purpose: Seed categories and products, testing domain constraints against invalid data

-- 1. Seed valid category and product data
INSERT INTO categories (category_name, description)
VALUES 
    ('Electronics', 'Gadgets, devices, and accessories'),
    ('Apparel', 'Clothing and wearable gear')
RETURNING category_id, category_name;

INSERT INTO products (category_id, sku, name, description, price, stock_quantity)
VALUES 
    (1, 'ELEC-LOGI-MX3', 'Logitech MX Master 3S', 'Wireless Ergonomic Mouse', 99.99, 50),
    (1, 'ELEC-KEYCH-K2', 'Keychron K2 V2', 'Wireless Mechanical Keyboard', 79.50, 30),
    (2, 'APPR-HOOD-BLK', 'Nexus Store Hoodie (Black)', '100% Cotton Heavyweight Hoodie', 49.00, 100)
RETURNING product_id, sku, name, price;

-- 2. Test CHECK constraint violation (Negative Price)
-- Expected Result: ERROR: new row for relation "products" violates check constraint "products_price_check"
INSERT INTO products (category_id, sku, name, price, stock_quantity)
VALUES (1, 'TEST-FAIL-01', 'Invalid Price Product', -10.00, 5);

-- 3. Test UNIQUE constraint violation (Duplicate SKU)
-- Expected Result: ERROR: duplicate key value violates unique constraint "products_sku_key"
INSERT INTO products (category_id, sku, name, price, stock_quantity)
VALUES (1, 'ELEC-LOGI-MX3', 'Duplicate Mouse SKU', 89.99, 10);