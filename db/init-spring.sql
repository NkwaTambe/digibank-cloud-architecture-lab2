-- =============================================================
-- Digi Bank (Spring Boot) — PostgreSQL initialisation script
-- UCC 122-1 · Cloud Architecture · Lab 3  (§3)
--
-- Run once as a superuser (e.g. postgres) before the first
-- application start:
--
--   sudo -u postgres psql -f db/init-spring.sql
--
-- NOTE: Unlike Lab 2, this script only creates the database and
-- the application user. The tables are created automatically by
-- Hibernate (spring.jpa.hibernate.ddl-auto=update) so that the
-- physical column names match Spring Boot's snake_case naming
-- strategy (e.g. first_name, last_name, account_number).
-- =============================================================

-- Refresh collation versions to avoid "collation version mismatch"
-- errors that occur when glibc is upgraded after cluster init.
ALTER DATABASE template1 REFRESH COLLATION VERSION;
ALTER DATABASE postgres  REFRESH COLLATION VERSION;

-- 3.1 Creating the database and the user
-- (guards prevent errors if the script is run more than once)

SELECT 'CREATE DATABASE digibank_db'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'digibank_db')\gexec

DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'digibank_user') THEN
    CREATE USER digibank_user WITH PASSWORD 'digibank_pwd';
  END IF;
END
$$;

GRANT ALL PRIVILEGES ON DATABASE digibank_db TO digibank_user;

-- Connect to digibank_db to grant schema permissions
\c digibank_db

GRANT ALL ON SCHEMA public TO digibank_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO digibank_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO digibank_user;

-- =============================================================
-- 3.2 Connection verification
-- After running this script, verify the connection with:
--
--   psql -U digibank_user -d digibank_db -h localhost
--
-- The connection must be accepted without error.
-- =============================================================
