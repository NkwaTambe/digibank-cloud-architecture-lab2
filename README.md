# Digi Bank — Modular Monolith (Jakarta EE)

> **UCC 122-1 · Cloud Architecture · Lab 2**
> Designing an initial monolithic architecture (Legacy application) for **Digi Bank** with Jakarta EE.
>
> *Cloud Computing Professional License — University of the Mountains*
> Supervisor: **Eng. Willy Damtchou** · June 2026

---

## Overview

This project is the deliverable for **Lab 2** of the Cloud Architecture course.
It implements a first operational version of **Digi Bank**, a secure transactional
system for managing customers, accounts, financial operations and compliance controls,
built as a **modular monolith** on **Jakarta EE 10** and deployed to **WildFly 33**.

The lab moves from the analysis carried out in Lab 1 to a concrete, executable
implementation that respects a complete technical structure and a logical order of
development.

## Architecture

A multi-module Maven project where each functional domain is an independent module,
assembled into a single deployable WAR by the `digibank-app` module.

```
digibank-parent/          (pom)   — root, dependency & plugin management
├── digibank-shared/      (jar)   — common model & DTOs (BaseEntity, ApiResponse)
├── digibank-customer/    (jar)   — customer domain (entity, repo, service, REST)
├── digibank-account/     (jar)   — account domain (entity, service, REST)
├── digibank-transaction/ (jar)   — transaction domain (entity, service, REST)
├── digibank-compliance/  (jar)   — compliance checks (service, REST)
├── digibank-index/       (war)   — web UI (IndexServlet + index.jsp)
└── digibank-app/         (war)   — assembly module, JAX-RS activation, persistence
```

### Module responsibilities

| Module | Packaging | Role |
| --- | --- | --- |
| `digibank-shared` | jar | `@MappedSuperclass` base entity, shared DTOs |
| `digibank-customer` | jar | Customer CRUD — JPA-backed entity, repository, service, REST resource |
| `digibank-account` | jar | Account management (in-memory store in this lab) |
| `digibank-transaction` | jar | Transaction recording (in-memory store in this lab) |
| `digibank-compliance` | jar | Transaction amount validation (≤ 10 000) |
| `digibank-index` | war | Landing page listing modules and REST endpoints |
| `digibank-app` | war | Assembly: JAX-RS `@ApplicationPath("/api")`, `persistence.xml`, overlays `digibank-index` |

## Tech Stack

| Layer | Technology |
| --- | --- |
| Language | Java 17 |
| Platform | Jakarta EE 10 (`jakarta.jakartaee-api`) |
| Build | Apache Maven (multi-module) |
| Persistence | JPA / Hibernate (Jakarta Persistence) |
| REST | JAX-RS |
| EJB | `@Stateless` session beans, `@Inject` CDI |
| Web | Servlet + JSP (index module) |
| Database | PostgreSQL 18 |
| Application server | WildFly 33.0.2.Final |
| Unit testing | JUnit 5 (Jupiter) |
| BDD testing | Cucumber 7 + JUnit Platform Suite |

## Prerequisites

- **JDK 17** (compatible with Jakarta EE)
- **Apache Maven** 3.9+
- **PostgreSQL** 18
- **WildFly** 33.0.2.Final
- **IntelliJ IDEA** (Community/Ultimate) or **VS Code** with Java extensions
- **Git**

## Setup

### 1. Database

```sql
CREATE DATABASE digibank_db;
CREATE USER digibank_user WITH PASSWORD 'digibank_pwd';
GRANT ALL PRIVILEGES ON DATABASE digibank_db TO digibank_user;
```

Verify the connection:

```bash
psql -U digibank_user -d digibank_db -h localhost
```

### 2. WildFly datasource

1. Place the PostgreSQL JDBC driver (`postgresql-42.7.x.jar`) and a `module.xml`
   in `WILDFLY_HOME/modules/system/layers/base/org/postgresql/main/`.
2. In `WILDFLY_HOME/standalone/configuration/standalone.xml`, declare the datasource
   and driver:

```xml
<datasource jndi-name="java:/jdbc/DigiBankDS" pool-name="DigiBankDS"
            enabled="true" use-java-context="true">
    <connection-url>jdbc:postgresql://localhost:5432/digibank_db</connection-url>
    <driver>postgresql</driver>
    <security user-name="digibank_user" password="digibank_pwd"/>
</datasource>

<driver name="postgresql" module="org.postgresql">
    <driver-class>org.postgresql.Driver</driver-class>
</driver>
```

3. Start WildFly and confirm the log line:
   `Bound data source [java:/jdbc/DigiBankDS]`

```bash
/path/to/wildfly/bin/standalone.sh   # Linux / macOS
# or
/path/to/wildfly/bin/standalone.bat   # Windows
```

## Build & Deploy

From the `digibank-parent` root:

```bash
# Full multi-module build
mvn clean install

# Package the assembly WAR
mvn -pl digibank-app clean package
```

### Option A — Manual deploy

```bash
cp digibank-app/target/digibank-app.war \
   /path/to/wildfly/standalone/deployments/
```

### Option B — Maven deploy (wildfly-maven-plugin)

1. Create a WildFly admin user:

```bash
/path/to/wildfly/bin/add-user.sh
# Type: Management User · username: admin · password: admin
```

2. Start WildFly, then from the project root:

```bash
mvn clean install wildfly:deploy
```

The application is available at:
**http://localhost:8080/digibank-app**

## REST API

Base URL: `http://localhost:8080/digibank-app/api/`

| Method | Endpoint | Description |
| --- | --- | --- |
| GET | `/api/index` | General information (landing page) |
| POST | `/api/customers` | Create a customer |
| GET | `/api/customers` | List all customers |
| GET | `/api/customers/{id}` | Get a customer by id |
| POST | `/api/accounts` | Create an account |
| GET | `/api/accounts` | List all accounts |
| POST | `/api/transactions` | Create a transaction |
| GET | `/api/transactions` | List all transactions |
| GET | `/api/compliance/validate/{amount}` | Validate a transaction amount (≤ 10 000) |

### Example

```bash
# Create a customer
curl -X POST http://localhost:8080/digibank-app/api/customers \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Ali","lastName":"Diallo","email":"ali.diallo@digibank.com"}'

# Compliance check
curl http://localhost:8080/digibank-app/api/compliance/validate/5000
curl http://localhost:8080/digibank-app/api/compliance/validate/25000
```

## Testing

### Unit tests (JUnit 5)

```bash
mvn test
```

`ComplianceServiceTest` verifies:
- `shouldAcceptAmountBelowLimit` — 5 000.0 is accepted
- `shouldRejectAmountAboveLimit` — 20 000.0 is rejected

### BDD scenarios (Cucumber)

Feature file: `src/test/resources/features/compliance.feature`

```gherkin
Feature: Transaction amount validation

  Scenario: Amount as agreed
    Given a transaction amount of 5000
    When the compliance check is performed
    Then the transaction is accepted

  Scenario: Incorrect amount
    Given a transaction amount of 20000
    When the compliance check is performed
    Then the transaction is rejected
```

Run with the Cucumber JUnit Platform suite runner `RunCucumberTest`.

## Project Structure

```
.
├── README.md
├── UCC122-1_ Cloud architecture Lab 2 EN.pdf   # Lab specification
├── digibank-parent/
│   ├── pom.xml
│   ├── digibank-shared/
│   ├── digibank-customer/
│   ├── digibank-account/
│   ├── digibank-transaction/
│   ├── digibank-compliance/
│   ├── digibank-index/
│   └── digibank-app/
└── .gitignore
```

## Evaluation

| Criterion | Weight |
| --- | --- |
| Environment installation & configuration | 10% |
| Multi-module Maven structure | 15% |
| Business module development | 30% |
| PostgreSQL & WildFly configuration | 15% |
| REST endpoints & application execution | 10% |
| JUnit tests | 10% |
| Cucumber scenarios | 10% |

## Learning Outcomes

- A1.1 Set up a complete Java/Jakarta EE development environment
- A1.2 Create and configure a multi-module Maven project
- A1.3 Structure a modular monolithic application around the domains
      `shared`, `customer`, `account`, `transaction`, `compliance` and `index`
- A1.4 Configure PostgreSQL and WildFly for application execution
- A1.5 Develop REST entities, services, repositories and resources
- A1.6 Run JUnit unit tests
- A1.7 Write and launch BDD scenarios with Cucumber
- A1.8 Deploy the application and verify that it is working correctly

## Next Steps

This first version prepares the ground for future work focusing on:
- Enriching the business domain
- Security
- Technical documentation
- Improving transactional robustness
- Increasing software quality

## License

Academic coursework — University of the Mountains, Cloud Computing Professional License.