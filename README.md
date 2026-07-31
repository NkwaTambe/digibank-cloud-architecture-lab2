# 🏦 Digi Bank — Modular Monolithic Banking System

> **UCC 122-1 · Cloud Architecture · Lab 2**  
> Designing an initial monolithic architecture (legacy banking application) for **Digi Bank** using **Jakarta EE 10** and **WildFly 33**.
> 
> *Professional Bachelor's Degree in Cloud Computing — University of the Mountains*  
> Supervisor: **Eng. Willy Damtchou** · June 2026

---

## 📌 Introduction

Welcome to the **Digi Bank Modular Monolith** codebase! This project is a complete guide to developing, testing, deploying, and containerizing a modular monolithic banking application using **Jakarta EE 10**, **Hibernate/JPA**, **PostgreSQL**, and **WildFly 33**. 

This document provides a highly detailed, step-by-step walkthrough to get the application up and running on your machine within minutes.

---

## 🏗 Modular Architecture Diagram

Rather than a distributed set of microservices, this application runs as a **Modular Monolith**. It is composed of multiple independent modules packaged into JARs, which are compiled and bundled together inside a single deployable Web Archive (`digibank-app.war`).

```
                              [ digibank-parent (Reactor POM) ]
                                              │
      ┌───────────────┬───────────────┬───────┴───────┬───────────────┬───────────────┐
      ▼               ▼               ▼               ▼               ▼               ▼
[Shared Module] [Customer Module] [Account Module] [Transaction] [Compliance]   [Index Module]
 (BaseEntity,      (JPA, EJB,      (In-memory,     (In-memory,    (Validation,     (IndexServlet,
 ApiResponse)      REST endpoints)  REST API)       REST API)       BDD tests)       index.jsp)
      │               │               │               │               │               │
      └───────────────┼───────────────┼───────────────┼───────────────┘               │
                      ▼               ▼               ▼                               │
                      [ Compiled JARs copied into WEB-INF/lib ]                       │
                                      │                                               │
                                      ▼                                               ▼
                                 [ digibank-app (WAR Assembly) ] ◀──────(Overlay)─────┘
```

---

## 🚀 1. Simple Getting Started Guide (Docker Mode)

This is the **easiest and recommended way** to run the project. You do not need to install Java, Maven, PostgreSQL, or WildFly on your host machine. Everything runs inside Docker.

### Prerequisite Check
Before starting, make sure you have **Docker** and **Docker Compose** installed:
```bash
docker --version
docker compose version
```

### Step 1: Run the Control Center
From the root of the project directory, execute the interactive script:
```bash
./setup.sh
```

### Step 2: Choose Option 1 (Docker Compose)
When the menu loads, type **`1`** and press **Enter**:
```text
  Enter choice (1-9): 1
```

### Step 3: What Happens Under the Hood
1. **Maven Build**: The script compiles the Java source files, runs the test suites, and compiles the `digibank-app.war` artifact.
2. **Database Launch**: Launches a PostgreSQL container (`digibank-db`) on host port `5434`. It automatically runs `db/init.sql` to configure database tables and permissions.
3. **WildFly Launch**: Builds and starts the WildFly server (`digibank-app`) on host port `9090`. It injects the JNDI Datasource mapping (`java:/jdbc/DigiBankDS`) and deploys the compiled WAR file.
4. **Endpoint Diagnostics**: The script polls the server and executes automated REST tests using `curl`.

**Expected Success Output:**
```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🏦 Testing REST Endpoints
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ✓ POST /api/customers (create) — HTTP 201
  ✓ GET /api/customers (list) — HTTP 200
  ✓ POST /api/accounts (create) — HTTP 201
  ✓ GET /api/accounts (list) — HTTP 200
  ✓ POST /api/transactions (create) — HTTP 201
  ✓ GET /api/transactions (list) — HTTP 200
  ✓ GET /api/compliance/validate/5000 — HTTP 200
  ✓ GET /api/compliance/validate/25000 — HTTP 200

  Results: 8 passed, 0 failed out of 8 endpoints
```

### Step 4: Access in the Browser
Open your web browser and navigate to:
- **Landing Web Portal**: [http://localhost:9090/digibank-app](http://localhost:9090/digibank-app)
- **REST APIs Endpoint**: [http://localhost:9090/digibank-app/api/index](http://localhost:9090/digibank-app/api/index)

### Step 5: Stop the Application
To stop the containers and clean up database volumes:
```bash
./setup.sh
```
Choose option **`2`** (Stop Docker Compose).

---

## 💻 2. Host-Side Setup Guide (Local Mode)

If you prefer to run the application natively on your operating system, follow this manual step-by-step guide.

### Prerequisites
Ensure the following tools are installed and in your environment PATH:
- **JDK 17** (or 21)
- **Apache Maven 3.8+**
- **PostgreSQL 16+**
- **WildFly 33.x**

---

### Step 1: Database Setup
Start your local PostgreSQL service and run the database initialization script:
```bash
sudo -u postgres psql -f db/init.sql
```
This script creates:
- Database: `digibank_db`
- User: `digibank_user` (Password: `digibank_pwd`)
- Role permissions.

To verify the connection:
```bash
psql -U digibank_user -d digibank_db -h localhost
```

---

### Step 2: WildFly Server Setup

1. **PostgreSQL Driver Configuration**:
   Create the directory `org/postgresql/main` inside WildFly's module directory:
   ```bash
   mkdir -p $WILDFLY_HOME/modules/system/layers/base/org/postgresql/main/
   ```
   Download and copy the JDBC driver jar (`postgresql-42.7.5.jar`) to this folder.
   
2. **Create Module Descriptor**:
   Create a new file `module.xml` inside that directory:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <module xmlns="urn:jboss:module:1.5" name="org.postgresql">
       <resources>
           <resource-root path="postgresql-42.7.5.jar" />
       </resources>
       <dependencies>
           <module name="javax.api" />
           <module name="javax.transaction.api" />
       </dependencies>
   </module>
   ```

3. **Declare Datasource in Standalone Config**:
   Open `$WILDFLY_HOME/standalone/configuration/standalone.xml` and insert the datasource configuration inside the `<datasources>` subsystem:
   ```xml
   <datasource jndi-name="java:/jdbc/DigiBankDS" pool-name="DigiBankDS" enabled="true" use-java-context="true">
       <connection-url>jdbc:postgresql://localhost:5432/digibank_db</connection-url>
       <driver>postgresql</driver>
       <security user-name="digibank_user" password="digibank_pwd"/>
   </datasource>
   ```
   Under the `<drivers>` section, register the driver:
   ```xml
   <driver name="postgresql" module="org.postgresql">
       <driver-class>org.postgresql.Driver</driver-class>
   </driver>
   ```

---

### Step 3: Compile, Package, and Deploy
Open a terminal in the project root:
1. **Compile and run tests**:
   ```bash
   cd digibank-parent
   mvn clean install
   ```
2. **Start your WildFly Server**:
   ```bash
   $WILDFLY_HOME/bin/standalone.sh
   ```
3. **Deploy the application**:
   ```bash
   mvn wildfly:deploy -pl digibank-app
   ```
4. **Access locally**: [http://localhost:8080/digibank-app](http://localhost:8080/digibank-app)

---

## 🧪 3. Quality Assurance (How to Run Tests)

The application has a robust unit and integration testing suite configured inside the `digibank-compliance` module.

### A. JUnit 5 Unit Tests
These check the functional logic of the stateless compliance service:
- Validates that amounts $\le 10000.0$ are accepted.
- Validates that amounts $> 10000.0$ are rejected.

### B. Cucumber BDD Scenarios
These run behavior validation using natural-language steps. The test features are located in [compliance.feature](file:///home/ariel/Desktop/udm/digibank-cloud-architecture-lab2/digibank-parent/digibank-compliance/src/test/resources/features/compliance.feature).

To run all tests from the root directory:
1. Start `./setup.sh`.
2. Choose option **`4`** (Run Maven Build & Tests).
3. Alternatively, run via Maven:
   ```bash
   cd digibank-parent
   mvn test -pl digibank-compliance
   ```

---

## 📡 4. REST API Endpoint Catalog

All REST resources are exposed under the `/api` root path.

### 👥 Customer Resource (`/api/customers`)
* **Create a Customer**:
  - **Method**: `POST`
  - **Request Body**:
    ```json
    {
      "firstName": "Ali",
      "lastName": "Diallo",
      "email": "ali.diallo@digibank.com"
    }
    ```
  - **Response (201 Created)**:
    ```json
    {
      "id": 1,
      "firstName": "Ali",
      "lastName": "Diallo",
      "email": "ali.diallo@digibank.com"
    }
    ```

* **List Customers**:
  - **Method**: `GET`
  - **Response (200 OK)**: List of JSON customer objects.

---

### 💳 Account Resource (`/api/accounts`)
* **Create an Account**:
  - **Method**: `POST`
  - **Request Body**:
    ```json
    {
      "accountNumber": "ACC-001",
      "balance": 1500.00
    }
    ```
  - **Response (201 Created)**:
    ```json
    {
      "accountNumber": "ACC-001",
      "balance": 1500.0
    }
    ```

* **List Accounts**:
  - **Method**: `GET`
  - **Response (200 OK)**: List of account objects.

---

### 💸 Transaction Resource (`/api/transactions`)
* **Create a Transaction**:
  - **Method**: `POST`
  - **Request Body**:
    ```json
    {
      "type": "DEPOSIT",
      "amount": 5000.00
    }
    ```
  - **Response (201 Created)**:
    ```json
    {
      "type": "DEPOSIT",
      "amount": 5000.0
    }
    ```

---

### 🛡 Compliance Resource (`/api/compliance`)
* **Validate Transaction Amount**:
  - **Method**: `GET`
  - **Path**: `/api/compliance/validate/{amount}`
  - **URL Examples**: 
    - `/api/compliance/validate/5000` (Returns `{"valid":true}`)
    - `/api/compliance/validate/25000` (Returns `{"valid":false}`)

---

## 🛠 5. Troubleshooting & Port Configurations

If you see port conflict errors when running Docker Compose:
- **Port 8080 or 8081 is busy**: The script binds WildFly HTTP to **`9090`** on your host. Make sure port `9090` is free.
- **Port 5432 or 5433 is busy**: The script binds PostgreSQL to port **`5434`** on your host. Make sure port `5434` is free.
- **Stop containers and release ports**:
  Run:
  ```bash
  docker compose down -v
  ```

---

## 📦 6. Deliverables Checklist (§14)

Before submitting your lab deliverables, verify that you have packaged:
1. `digibank-parent/` directory (including the 7 Maven child modules).
2. The interactive script: `setup.sh`
3. `db/init.sql` database configuration file.
4. JUnit & Cucumber test files under `digibank-compliance/src/test`.
5. CDI bean configurations (`beans.xml` in resources/META-INF directories).
6. **[DEVELOPMENT_NOTES.md](file:///home/ariel/Desktop/udm/digibank-cloud-architecture-lab2/DEVELOPMENT_NOTES.md)** explaining the development order and difficulties.