# 🏦 Digi Bank (Spring Boot) — Modular Monolithic Banking System

> **UCC 122-1 · Cloud Architecture · Lab 3**
> Designing a monolithic architecture for **Digi Bank** using **Spring Boot 3.5**, **Spring Web**, **Spring Data JPA**, **PostgreSQL**, and **WildFly 33**.
>
> *Professional Bachelor's Degree in Cloud Computing — University of the Mountains*
> Supervisor: **Eng. Willy Damtchou** · June 2026

---

## 📌 Introduction

This is the **Lab 3** reference implementation of the Digi Bank modular monolith, rebuilt with the **Spring ecosystem** while keeping the exact same functional scope and module layout as the Lab 2 (Jakarta EE) version. It demonstrates that the same system can be implemented with different technical frameworks while preserving the same requirements for modularity, persistence, API exposure, testability, and deployment.

The application is packaged as a **WAR** and deployed on **WildFly** as an external runtime container, using a main class that extends `SpringBootServletInitializer`.

---

## 🏗 Modular Architecture

```
                    [ digibank-parent-spring (Reactor POM) ]
                                    │
      ┌──────────┬──────────┬───────┴───────┬──────────┬──────────┐
      ▼          ▼          ▼               ▼          ▼          ▼
[Shared]   [Customer]   [Account]      [Transaction] [Compliance] [Index]
(BaseEntity, (JPA, Spring (JPA, Spring  (JPA, Spring  (Validation, (Thymeleaf
 ApiResponse) Data, REST)  Data, REST)   Data, REST)   BDD tests)   home page)
      │          │          │               │          │           │
      └──────────┴──────────┴───────────────┴──────────┴───────────┘
                                    │
                                    ▼
                    [ digibank-app (WAR Assembly) ]
```

The 7 modules are compiled into JARs and bundled into a single deployable `digibank-app.war`.

---

## 🚀 Quick Start (One Script)

The easiest way to build, deploy, and test the whole application is a single command:

```bash
./setup-spring.sh docker
```

This will:
1. **Build** the Maven project (`mvn clean install`) and produce `digibank-app.war`.
2. **Start** PostgreSQL + WildFly + Adminer via Docker Compose (`docker-compose.spring.yml`).
3. **Deploy** the WAR on WildFly (datasource `java:/jdbc/DigiBankDS` is configured automatically).
4. **Test** all REST endpoints and report pass/fail.

### Other commands

```bash
./setup-spring.sh            # Interactive menu
./setup-spring.sh docker     # Build + start + deploy + test (recommended)
./setup-spring.sh docker-down# Stop containers and clean volumes
./setup-spring.sh build      # Maven build only (compile + test)
./setup-spring.sh test       # Run tests only (JUnit + Cucumber)
./setup-spring.sh endpoints  # Test all REST endpoints
./setup-spring.sh check      # Check prerequisites (Java, Maven, Docker)
```

### Access

| Resource | URL |
|---|---|
| Landing page | http://localhost:9091/digibank-app |
| REST API base | http://localhost:9091/digibank-app/api/ |
| Adminer (DB) | http://localhost:8083 |

> **Note:** The Spring profile uses ports `9091` (WildFly), `5435` (PostgreSQL) and `8083` (Adminer) so it can run **alongside** the Lab 2 Docker setup without conflicts.

---

## 🧪 Tests

- **JUnit 5** unit tests: `digibank-compliance/src/test/.../ComplianceServiceTest.java`
- **Cucumber BDD**: `compliance.feature` + `ComplianceSteps` + `RunCucumberTest` suite runner.

Run them with:

```bash
cd digibank-parent-spring
mvn test
```

---

## 📡 REST API Endpoint Catalog

All endpoints are exposed under `/api`.

| Method | Endpoint | Description |
|---|---|---|
| POST | `/api/customers` | Create a customer |
| GET | `/api/customers` | List customers |
| GET | `/api/customers/{id}` | Get a customer by id |
| POST | `/api/accounts` | Create an account |
| GET | `/api/accounts` | List accounts |
| GET | `/api/accounts/{id}` | Get an account by id |
| POST | `/api/transactions` | Create a transaction |
| GET | `/api/transactions` | List transactions |
| GET | `/api/transactions/{id}` | Get a transaction by id |
| GET | `/api/compliance/validate/{amount}` | Validate a transaction amount |

Example:

```bash
curl -X POST http://localhost:9091/digibank-app/api/customers \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Ali","lastName":"Diallo","email":"ali.diallo@digibank.com"}'
```

---

## 🛠 Configuration

- **Datasource**: JNDI `java:/jdbc/DigiBankDS` (declared in WildFly, see `Dockerfile.wildfly`).
- **JPA**: `spring.jpa.hibernate.ddl-auto=update` — Hibernate creates/updates the tables.
- **Database**: `digibank_db` / user `digibank_user` / password `digibank_pwd` (see `db/init-spring.sql`).

---

## 📦 Deliverables

1. `digibank-parent-spring/` — complete multi-module Maven project (7 modules).
2. All `pom.xml` files.
3. Configuration files (`application.properties`, `docker-compose.spring.yml`, `Dockerfile.wildfly`).
4. SQL script: `db/init-spring.sql`.
5. Spring Boot Java classes (entities, repositories, services, controllers).
6. JUnit tests.
7. Cucumber scenarios.
8. `docs/development_notes_spring.md` — development order and difficulties.
