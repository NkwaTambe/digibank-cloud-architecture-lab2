# 🏦 Digi Bank — Documentation: Architecture, Design & Patterns

> **UCC 122-1 · Cloud Architecture · Lab 2**  
> Technical specifications, class models, and cloud strategy.

---

## 🏛 1. Core Enterprise Design Patterns

This project follows enterprise-level design patterns defined by the Jakarta EE architecture.

### Dependency Injection (CDI 4.0)
- **Pattern**: Contexts and Dependency Injection (CDI) decouples bean creation from utilization.
- **Implementation**: Enabled explicitly by adding `beans.xml` with `bean-discovery-mode="all"` in the `META-INF` directories.
- **Example**: In `CustomerService.java`, the repository is injected:
  ```java
  @Inject
  private CustomerRepository repository;
  ```

### Stateless Session Beans (EJB 3.2)
- **Pattern**: Business services and repositories are marked as `@Stateless` Enterprise Java Beans.
- **Benefits**:
  - **Automatic Transaction Management (JTA)**: Operations are wrapped in container-managed transaction boundaries.
  - **Thread-Safety**: EJBs are pooled; the container ensures that each instance is accessed by only one thread at a time.
  - **Resource Injection**: Injects persistent context (`EntityManager`) directly.

### JAX-RS REST Web Services
- **Pattern**: REST resources are configured as entry points for HTTP clients.
- **Implementation**: The servlet mapping is activated globally in the `digibank-app` assembly using:
  ```java
  @ApplicationPath("/api")
  public class DigiBankApplication extends Application {}
  ```
- **Negotiation**: Uses JSON mapping natively (`MediaType.APPLICATION_JSON`) to serialize and deserialize data.

---

## 💾 2. JPA & Database Schema Details

The application uses Java Persistence API (JPA) annotations to define entities and map them to physical tables in PostgreSQL.

```
       +---------------------------------------------+
       |                  BaseEntity                 |
       |  (@MappedSuperclass, Generated Long id)     |
       +---------------------------------------------+
                              ▲
            ┌─────────────────┼─────────────────┐
            │                 │                 │
     +──────────────+  +──────────────+  +──────────────+
     |   Customer   |  |    Account   |  |  Transaction |
     |  (customers) |  |   (accounts) |  | (transactions|
     +──────────────+  +──────────────+  +──────────────+
```

### Table Mappings
- **Customer Entity** (`com.digibank.customer.model.Customer`):
  * **Table Name**: `customers`
  * **Primary Key**: `id` (Auto-incrementing `BIGINT`)
  * **Columns**:
    - `first_name` (VARCHAR, non-nullable)
    - `last_name` (VARCHAR, non-nullable)
    - `email` (VARCHAR, non-nullable, unique)

- **Account Entity** (`com.digibank.account.model.Account`):
  * **Table Name**: `accounts`
  * **Columns**:
    - `account_number` (VARCHAR, non-nullable, unique)
    - `balance` (DOUBLE PRECISION, non-nullable)

- **Transaction Entity** (`com.digibank.transaction.model.Transaction`):
  * **Table Name**: `transactions`
  * **Columns**:
    - `type` (VARCHAR, non-nullable)
    - `amount` (DOUBLE PRECISION, non-nullable)

---

## 🧪 3. Detailed Test Design (BDD & TDD)

We implement both Unit Testing and Behavior-Driven Development (BDD).

### Compliance Rules
The system enforces validation on transaction amounts (must be $\le 10,000$).

### 1. Unit testing (TDD-style)
The `ComplianceServiceTest.java` class isolates the Java business service class. It executes directly on the JVM without container overhead, allowing lightning-fast tests.
- **Success Criteria**: Returns true for input `5000.0`, false for input `20000.0`.

### 2. Integration / Acceptance Testing (BDD Cucumber-style)
BDD scenarios bridge business goals and programming steps.
- **Given** defines the initial state (the transaction amount).
- **When** defines the action (compliance check is executed).
- **Then** defines the expected result (accepted or rejected).

The mapping is compiled and run inside `RunCucumberTest.java` utilizing JUnit 5 suite extensions:
```java
@Suite
@IncludeEngines("cucumber")
@SelectClasspathResource("features")
public class RunCucumberTest {}
```

---

## 🐳 4. Virtualization & Container Configuration

```
   [ Host Machine ]
          │
          ▼ (Ports: 9090 & 5434)
+─────────────────────────────────────────+
|             Docker Network              |
|                                         |
|   [ Container: db ] ◀──(Port 5432)──┐   |
|   (PostgreSQL 16)                   │   |
|                                     │   |
|   [ Container: wildfly ] ───────────┘   |
|   (WildFly 33, maps Datasource)         |
+─────────────────────────────────────────+
```

### 1. Database Container (`db`)
- Uses image `postgres:16`.
- Binds internally to `5432` and exposes to host on port `5434`.
- **Database Name**: `digibank_db`
- **Username**: `digibank_user`
- **Password**: `digibank_pwd`
- Mounts [init.sql](file:///home/ariel/Desktop/udm/digibank-cloud-architecture-lab2/db/init.sql) directly to `/docker-entrypoint-initdb.d/init.sql` to execute database schema migrations on start.

### 2. Application Server Container (`wildfly`)
- Uses image `quay.io/wildfly/wildfly:33.0.2.Final-jdk17`.
- Binds internally to `8080` (HTTP) and `9990` (Management console).
- Exposes port `9090` (HTTP) and `9999` (Management) to the host.
- Mounts the compiled WAR target artifact: `/opt/jboss/wildfly/standalone/deployments/digibank-app.war`.
- Maps database connection URL to `jdbc:postgresql://db:5432/digibank_db` (using the container hostname `db` in the Docker network).
- Configures the JNDI datasource pre-startup via `jboss-cli.sh`.
