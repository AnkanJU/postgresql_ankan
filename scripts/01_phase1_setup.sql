-- Phase 1 - Lesson 1: System Verification Query
-- Purpose: Verify PostgreSQL engine connection and retrieve system metadata

SELECT 
    version() AS postgresql_version,
    current_database() AS current_db,
    current_user AS connected_user;