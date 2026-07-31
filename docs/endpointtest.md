# DigiBank API Endpoint Test Cases

This document lists the `curl` commands for testing and validating the DigiBank JAX-RS REST endpoints. 
These tests assume the DigiBank application is running on WildFly (either via Docker Compose or locally) and is accessible at `http://localhost:9090/digibank-app`.

---

## Base Configuration
- **Base API URL:** `http://localhost:9090/digibank-app/api`
- **Headers Required:** `Content-Type: application/json`

---

## 1. Customers Module

### Create a Customer
Create a new customer profile.
```bash
curl -X POST http://localhost:9090/digibank-app/api/customers \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Ali",
    "lastName": "Diallo",
    "email": "ali.diallo@digibank.com"
  }'
```
**Expected Response:** `211 Created` or `201 Created` containing the created customer JSON:
```json
{"id":1,"firstName":"Ali","lastName":"Diallo","email":"ali.diallo@digibank.com"}
```

### List All Customers
Retrieve all registered customers.
```bash
curl -X GET http://localhost:9090/digibank-app/api/customers
```
**Expected Response:** `200 OK` with an array of customers.

### Find Customer by ID
Retrieve a specific customer by their database ID.
```bash
curl -X GET http://localhost:9090/digibank-app/api/customers/1
```
**Expected Response:** `200 OK` with the customer details, or `404 Not Found` if the customer does not exist.

---

## 2. Accounts Module

### Create an Account
Create a new bank account.
```bash
curl -X POST http://localhost:9090/digibank-app/api/accounts \
  -H "Content-Type: application/json" \
  -d '{
    "accountNumber": "ACC-001",
    "balance": 1500.00
  }'
```
**Expected Response:** `201 Created` with the created account details.

### List All Accounts
Retrieve all active bank accounts.
```bash
curl -X GET http://localhost:9090/digibank-app/api/accounts
```
**Expected Response:** `200 OK` with a JSON array of accounts.

---

## 3. Transactions Module

### Create a Transaction
Submit a transaction (e.g., DEPOSIT or WITHDRAWAL).
```bash
curl -X POST http://localhost:9090/digibank-app/api/transactions \
  -H "Content-Type: application/json" \
  -d '{
    "type": "DEPOSIT",
    "amount": 5000.00
  }'
```
**Expected Response:** `201 Created` with the transaction details.

### List All Transactions
Retrieve transaction history.
```bash
curl -X GET http://localhost:9090/digibank-app/api/transactions
```
**Expected Response:** `200 OK` with a JSON array of transactions.

---

## 4. Compliance Module

The compliance module automatically validates if a transaction amount exceeds regulatory reporting limits (threshold is generally 10,000).

### Validate Transaction - Under Limit
Validate an amount below the compliance limit.
```bash
curl -X GET http://localhost:9090/digibank-app/api/compliance/validate/5000
```
**Expected Response:** `200 OK` with a validation message or boolean:
```json
true
```

### Validate Transaction - Over Limit (Requires Reporting)
Validate an amount above the compliance limit.
```bash
curl -X GET http://localhost:9090/digibank-app/api/compliance/validate/25000
```
**Expected Response:** `200 OK` showing that the amount has triggered compliance rules/reporting requirements (e.g., `false` or compliance failure object).
