-- =============================================================
-- Digi Bank — PostgreSQL initialisation script
-- UCC 122-1 · Cloud Architecture · Lab 2  (§3)
--
-- Run once as a superuser (e.g. postgres) before the first
-- application start:
--
--   sudo -u postgres psql -f db/init.sql
--
-- If the cluster was initialized on an older glibc and the OS
-- has since been upgraded, run this script as-is — the collation
-- refresh statements below prevent the template1 mismatch error.
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
  ELSE
    ALTER USER digibank_user WITH PASSWORD 'digibank_pwd';
  END IF;
END
$$;

GRANT ALL PRIVILEGES ON DATABASE digibank_db TO digibank_user;

-- =============================================================
-- 3.2 Connection verification
-- After running this script, verify the connection with:
--
--   psql -U digibank_user -d digibank_db -h localhost
--
-- Expected result (§3.3):
--   psql (18.x)
--   Type "help" for help.
--   digibank_db=>
--
-- The connection must be accepted without error.
-- =============================================================
