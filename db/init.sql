-- =============================================================
-- Digi Bank — PostgreSQL initialisation script
-- UCC 122-1 · Cloud Architecture · Lab 2  (§3)
--
-- Run once as a superuser (e.g. postgres) before the first
-- application start:
--
--   psql -U postgres -f db/init.sql
-- =============================================================

-- 3.1 Creating the database and the user
-- (run as superuser — skip CREATE DATABASE if it already exists)

CREATE DATABASE digibank_db;

CREATE USER digibank_user WITH PASSWORD 'digibank_pwd';

GRANT ALL PRIVILEGES ON DATABASE digibank_db TO digibank_user;

-- =============================================================
-- 3.2 Connection verification
-- After running this script, verify the connection with:
--
--   psql -U digibank_user -d digibank_db -h localhost
--
-- Expected result (§3.3):
--   psql (18.4)
--   Type "help" for help.
--   digibank_db=>
--
-- The connection must be accepted without error.
-- =============================================================
