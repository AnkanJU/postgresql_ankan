-- Phase 5 - Lesson 17: Database Security & Maintenance Administration
-- Purpose: Create application roles, grant permissions, and run storage maintenance

-- 1. Create restricted application role (Principle of Least Privilege)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'nexus_app_user') THEN
        CREATE ROLE nexus_app_user WITH LOGIN PASSWORD 'SecureAppPass123!';
    END IF;
END
$$;

-- Grant connectivity and standard DML rights
GRANT CONNECT ON DATABASE nexus_store TO nexus_app_user;
GRANT USAGE ON SCHEMA public TO nexus_app_user;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO nexus_app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO nexus_app_user;

-- Revoke high-risk administrative DDL rights from application user
REVOKE TRUNCATE, DROP ON ALL TABLES IN SCHEMA public FROM nexus_app_user;


-- 2. Execute Maintenance Commands (Update Planner Stats)
ANALYZE VERBOSE users;
ANALYZE VERBOSE products;
ANALYZE VERBOSE orders;