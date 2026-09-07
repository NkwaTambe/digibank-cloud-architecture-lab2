-- Digi Bank microservices — database bootstrap script.
--
-- Creates the dedicated databases and the application role used by the services.
-- Run as the PostgreSQL superuser and supply the password via a psql variable so
-- no secret is hardcoded in the repository:
--
--   psql -U postgres -v db_password='your-secret' -f init-databases.sql
--
-- NOTE: when running through docker-compose the databases and role are created
-- automatically from the POSTGRES_DB / POSTGRES_USER / POSTGRES_PASSWORD
-- environment variables (see docker-compose.yml and .env), so this script is only
-- needed for manual / standalone PostgreSQL setups.

CREATE DATABASE digibank_customer_db;
CREATE DATABASE digibank_account_db;
CREATE DATABASE digibank_transaction_db;
CREATE DATABASE digibank_compliance_db;
CREATE DATABASE digibank_notification_db;

CREATE USER digibankuser WITH PASSWORD :'db_password';

GRANT ALL PRIVILEGES ON DATABASE digibank_customer_db TO digibankuser;
GRANT ALL PRIVILEGES ON DATABASE digibank_account_db TO digibankuser;
GRANT ALL PRIVILEGES ON DATABASE digibank_transaction_db TO digibankuser;
GRANT ALL PRIVILEGES ON DATABASE digibank_compliance_db TO digibankuser;
GRANT ALL PRIVILEGES ON DATABASE digibank_notification_db TO digibankuser;
