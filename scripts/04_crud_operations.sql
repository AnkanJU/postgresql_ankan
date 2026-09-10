-- Phase 1 - Lesson 4: Basic DML Operations
-- Purpose: Perform foundational CRUD operations on the users table

-- 1. INSERT: Create initial test users
INSERT INTO users (full_name, email, password_hash)
VALUES 
    ('Ankan Roy', 'ankan@nexusstore.com', 'hashed_pass_123'),
    ('John Doe', 'john.doe@example.com', 'hashed_pass_456'),
    ('Jane Smith', 'jane.smith@example.com', 'hashed_pass_789');

-- 2. SELECT: Retrieve all active users
SELECT user_id, full_name, email, is_active, created_at 
FROM users 
WHERE is_active = TRUE;

-- 3. UPDATE: Update email address for a specific user
UPDATE users 
SET email = 'ankan.roy@nexusstore.com' 
WHERE full_name = 'Ankan Roy';

-- 4. DELETE: Remove a specific test user
DELETE FROM users 
WHERE email = 'john.doe@example.com';

-- 5. SELECT: Final verification query
SELECT user_id, full_name, email, is_active 
FROM users;