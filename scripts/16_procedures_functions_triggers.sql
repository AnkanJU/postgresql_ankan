-- Phase 5 - Lesson 16: PL/pgSQL Functions, Procedures, and Triggers
-- Purpose: Implement automated business logic and inventory tracking triggers

-- 1. Create a Function to calculate tax and final total
CREATE OR REPLACE FUNCTION fn_calculate_order_total(
    p_subtotal NUMERIC(10, 2),
    p_tax_rate NUMERIC(4, 3) DEFAULT 0.080
)
RETURNS NUMERIC(10, 2) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN ROUND(p_subtotal + (p_subtotal * p_tax_rate), 2);
END;
$$;


-- 2. Create an Inventory Audit Table & Trigger Function
CREATE TABLE IF NOT EXISTS inventory_audit_log (
    audit_id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    old_stock INT NOT NULL,
    new_stock INT NOT NULL,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION fn_log_inventory_change()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
    -- Only log when stock quantity actually changes
    IF OLD.stock_quantity <> NEW.stock_quantity THEN
        INSERT INTO inventory_audit_log (product_id, old_stock, new_stock)
        VALUES (NEW.product_id, OLD.stock_quantity, NEW.stock_quantity);
    END IF;
    RETURN NEW;
END;
$$;

-- Bind the trigger function to updates on the products table
DROP TRIGGER IF EXISTS trg_audit_product_stock ON products;

CREATE TRIGGER trg_audit_product_stock
AFTER UPDATE OF stock_quantity ON products
FOR EACH ROW
EXECUTE FUNCTION fn_log_inventory_change();


-- 3. Create a Stored Procedure to safely deduct inventory
CREATE OR REPLACE PROCEDURE sp_deduct_inventory(
    p_product_id BIGINT,
    p_quantity_deducted INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_stock INT;
BEGIN
    -- Fetch current stock level
    SELECT stock_quantity INTO v_current_stock
    FROM products
    WHERE product_id = p_product_id;

    IF v_current_stock IS NULL THEN
        RAISE EXCEPTION 'Product ID % does not exist', p_product_id;
    END IF;

    IF v_current_stock < p_quantity_deducted THEN
        RAISE EXCEPTION 'Insufficient inventory. Available: %, Requested: %', v_current_stock, p_quantity_deducted;
    END IF;

    -- Deduct inventory
    UPDATE products
    SET stock_quantity = stock_quantity - p_quantity_deducted
    WHERE product_id = p_product_id;

    RAISE NOTICE 'Inventory updated successfully for product %', p_product_id;
END;
$$;

-- 4. Test execution of function, trigger, and procedure
-- Test Function
SELECT fn_calculate_order_total(100.00, 0.10) AS calculated_total;

-- Test Stored Procedure (which fires the Trigger automatically)
CALL sp_deduct_inventory(1, 5);

-- Verify Trigger logged the stock change
SELECT * FROM inventory_audit_log;