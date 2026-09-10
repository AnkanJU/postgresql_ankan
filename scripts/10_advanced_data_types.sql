-- Phase 2 - Lesson 10: Advanced Data Types (ENUM, UUID, JSONB)
-- Purpose: Extend products with flexible JSONB attributes and update orders using ENUM and UUID

-- 1. Create custom ENUM type for Order Status
CREATE TYPE order_status_enum AS ENUM ('pending', 'processing', 'shipped', 'delivered', 'cancelled');

-- 2. Add UUID and JSONB columns to products
ALTER TABLE products 
ADD COLUMN product_guid UUID DEFAULT gen_random_uuid(),
ADD COLUMN attributes JSONB DEFAULT '{}'::jsonb;

-- 3. Update existing products with category-specific JSONB attributes
UPDATE products 
SET attributes = '{"brand": "Logitech", "wireless": true, "dpi": 8000}'::jsonb 
WHERE sku = 'ELEC-LOGI-MX3';

UPDATE products 
SET attributes = '{"brand": "Keychron", "switches": "Gateron Brown", "backlight": "RGB"}'::jsonb 
WHERE sku = 'ELEC-KEYCH-K2';

-- 4. Query JSONB fields directly using containment and extraction operators (->, ->>)
SELECT 
    name,
    sku,
    product_guid,
    attributes->>'brand' AS brand_name,
    attributes->>'wireless' AS is_wireless
FROM products
WHERE (attributes->>'wireless')::boolean = TRUE;