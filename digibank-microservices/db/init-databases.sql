CREATE DATABASE digibank_customer_db;
CREATE DATABASE digibank_account_db;
CREATE DATABASE digibank_transaction_db;
CREATE DATABASE digibank_compliance_db;
CREATE DATABASE digibank_notification_db;

CREATE USER digibankuser WITH PASSWORD 'digibankpwd';

GRANT ALL PRIVILEGES ON DATABASE digibank_customer_db TO digibankuser;
GRANT ALL PRIVILEGES ON DATABASE digibank_account_db TO digibankuser;
GRANT ALL PRIVILEGES ON DATABASE digibank_transaction_db TO digibankuser;
GRANT ALL PRIVILEGES ON DATABASE digibank_compliance_db TO digibankuser;
GRANT ALL PRIVILEGES ON DATABASE digibank_notification_db TO digibankuser;
