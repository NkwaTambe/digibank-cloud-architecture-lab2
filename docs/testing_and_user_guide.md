# Digi Bank — End-to-End Testing & User Guide

This guide covers how to set up, build, deploy, and test the entire **Digi Bank** stack — including the newly implemented **JPA Persistence** for `Account` and `Transaction` modules.

---

## 1. Quick Start via Control Center (`setup.sh`)

The repository includes an interactive control center script (`setup.sh`).

### A. Run via Docker Compose (Recommended)
This method spins up PostgreSQL 18, WildFly 33, Adminer (DB management UI), compiles all Maven sub-modules, deploys the WAR, and runs endpoint sanity checks automatically.

```bash
# Make script executable
chmod +x setup.sh

# Option 1: Interactive Menu
./setup.sh

# Option 2: Direct command
./setup.sh docker
```

Once running:
- **Application URL**: [http://localhost:9090/digibank-app](http://localhost:9090/digibank-app)
- **REST API Entry**: [http://localhost:9090/digibank-app/api/index](http://localhost:9090/digibank-app/api/index)
- **Swagger Interactive Docs**: [http://localhost:9090/digibank-app/swagger.html](http://localhost:9090/digibank-app/swagger.html)
- **Adminer DB Manager**: [http://localhost:8082](http://localhost:8082) (Server: `db`, User: `digibank_user`, Pass: `digibank_pwd`, DB: `digibank_db`)

To stop Docker services:
```bash
./setup.sh docker-down
```

---

## 2. Manual Local Setup & Testing

If you prefer to run PostgreSQL and WildFly locally on your host machine:

### A. Database Initialization
Execute the SQL initialization script against PostgreSQL:

```bash
psql -U postgres -f db/init.sql
```

Verify database connection:
```bash
psql -U digibank_user -d digibank_db -h localhost
```

### B. Maven Build & Unit/BDD Tests
Run unit tests (JUnit 5) and BDD scenarios (Cucumber):

```bash
# From root directory or digibank-parent
mvn clean test
```

### C. WildFly Deployment
1. Package the root parent and assembly WAR:
   ```bash
   mvn clean install
   ```
2. Copy the generated deployment artifact to WildFly:
   ```bash
   cp digibank-parent/digibank-app/target/digibank-app.war $WILDFLY_HOME/standalone/deployments/
   ```
3. Or deploy via WildFly Maven Plugin (if WildFly is running locally):
   ```bash
   mvn clean install wildfly:deploy
   ```

---

## 3. Testing REST Endpoints & JPA Persistence

Below is a complete test sequence verifying Customer, Account, Transaction, and Compliance REST endpoints backed by PostgreSQL JPA persistence.

### Step 1: Health & Landing Page Check
```bash
# HTML Landing Web Page (index.jsp portal)
curl -X GET http://localhost:9090/digibank-app/api/index

# REST API JSON Endpoint Sanity Check
curl -X GET http://localhost:9090/digibank-app/api/customers
```
**Expected Response**: `GET /api/index` returns the HTML web portal page, while `GET /api/customers` returns a JSON array of customer records.

---

### Step 2: Create & Query Customers (JPA Table: `customers`)
```bash
# Create Customer 1
curl -X POST http://localhost:9090/digibank-app/api/customers \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Alice","lastName":"Smith","email":"alice.smith@digibank.com"}'

# Create Customer 2
curl -X POST http://localhost:9090/digibank-app/api/customers \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Bob","lastName":"Jones","email":"bob.jones@digibank.com"}'

# List All Customers
curl -X GET http://localhost:9090/digibank-app/api/customers
```

---

### Step 3: Create & Query Accounts (JPA Table: `accounts`)
*Note: With our new JPA implementation, accounts are permanently stored in PostgreSQL `accounts` table.*

```bash
# Create Account 1
curl -X POST http://localhost:9090/digibank-app/api/accounts \
  -H "Content-Type: application/json" \
  -d '{"accountNumber":"ACC-1001","balance":5000.00}'

# Create Account 2
curl -X POST http://localhost:9090/digibank-app/api/accounts \
  -H "Content-Type: application/json" \
  -d '{"accountNumber":"ACC-1002","balance":12500.50}'

# List All Accounts
curl -X GET http://localhost:9090/digibank-app/api/accounts
```

---

### Step 4: Create & Query Transactions (JPA Table: `transactions`)
*Note: Transactions are now persisted directly into PostgreSQL `transactions` table.*

```bash
# Create Deposit Transaction
curl -X POST http://localhost:9090/digibank-app/api/transactions \
  -H "Content-Type: application/json" \
  -d '{"type":"DEPOSIT","amount":1500.00}'

# Create Transfer Transaction
curl -X POST http://localhost:9090/digibank-app/api/transactions \
  -H "Content-Type: application/json" \
  -d '{"type":"TRANSFER","amount":3000.00}'

# List All Transactions
curl -X GET http://localhost:9090/digibank-app/api/transactions
```

---

### Step 5: Compliance Checks
```bash
# Test Valid Amount (<= 10000)
curl -X GET http://localhost:9090/digibank-app/api/compliance/validate/5000

# Test Invalid Amount (> 10000)
curl -X GET http://localhost:9090/digibank-app/api/compliance/validate/25000
```

---

## 4. Verifying Database Persistence directly via SQL

To verify that data persists across application or container restarts, inspect PostgreSQL tables:

```bash
psql -U digibank_user -d digibank_db -h localhost -c "SELECT * FROM customers;"
psql -U digibank_user -d digibank_db -h localhost -c "SELECT * FROM accounts;"
psql -U digibank_user -d digibank_db -h localhost -c "SELECT * FROM transactions;"
```

Or visit Adminer at **[http://localhost:8082](http://localhost:8082)** to view tables visually.
