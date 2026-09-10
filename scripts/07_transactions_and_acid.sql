-- Phase 1 - Lesson 7: Transactions and ACID Compliance
-- Purpose: Demonstrate atomic execution using BEGIN, COMMIT, and ROLLBACK

-- -------------------------------------------------------------
-- Scenario A: Successful Order Payment Transaction (COMMIT)
-- -------------------------------------------------------------
BEGIN;

-- Step 1: Create a new order for user_id 1
INSERT INTO orders (user_id, total_amount, status)
VALUES (1, 89.99, 'pending')
RETURNING order_id, status;

-- Step 2: Update the order status to 'completed'
UPDATE orders
SET status = 'completed'
WHERE user_id = 1 AND status = 'pending';

-- Save all changes permanently
COMMIT;


-- -------------------------------------------------------------
-- Scenario B: Failed Transaction Reversal (ROLLBACK)
-- -------------------------------------------------------------
BEGIN;

-- Step 1: Attempt to create an order with an invalid negative amount (triggers CHECK constraint failure)
-- Or simulate an intentional manual rollback
INSERT INTO orders (user_id, total_amount, status)
VALUES (1, 45.00, 'processing');

-- Imagine an application error occurred here; undo all uncommitted work:
ROLLBACK;


-- -------------------------------------------------------------
-- Verification Query
-- -------------------------------------------------------------
SELECT order_id, user_id, total_amount, status, created_at 
FROM orders 
WHERE user_id = 1;