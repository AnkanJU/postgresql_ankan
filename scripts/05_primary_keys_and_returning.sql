-- Phase 1 - Lesson 5: Auto-Incrementing Sequences and RETURNING
-- Purpose: Demonstrate auto-generated primary keys and capture output with RETURNING

-- 1. INSERT a single record and immediately return its generated ID and default timestamps
INSERT INTO users (full_name, email, password_hash)
VALUES ('Michael Scott', 'michael@dundermifflin.com', 'hashed_pass_999')
RETURNING user_id, full_name, is_active, created_at;

-- 2. INSERT multiple records in bulk and return all generated user_ids
INSERT INTO users (full_name, email, password_hash)
VALUES 
    ('Dwight Schrute', 'dwight@dundermifflin.com', 'hashed_pass_888'),
    ('Jim Halpert', 'jim@dundermifflin.com', 'hashed_pass_777')
RETURNING user_id, email;

-- 3. UPDATE a record and use RETURNING to confirm the modified state
UPDATE users
SET is_active = FALSE
WHERE email = 'michael@dundermifflin.com'
RETURNING user_id, full_name, is_active;