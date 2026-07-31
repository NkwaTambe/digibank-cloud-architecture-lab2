# Digi Bank — Lab 2 Project Status Analysis

> **UCC 122-1 · Cloud Architecture · Lab 2**
> Analysis date: 2026-07-30

---

## Lab Overview

This lab requires building a **modular monolith** banking application using **Jakarta EE 10**, deployed on **WildFly 33**, backed by **PostgreSQL**, with **JUnit 5** unit tests and **Cucumber BDD** scenarios. The project is structured as a multi-module Maven project with 7 modules.

### The 13 Tasks Assigned to Students (§13)

1. Install the complete development environment
2. Configure IntelliJ IDEA or VS Code
3. Create the PostgreSQL database and the application user
4. Build the multi-module Maven structure
5. Create all the pom.xml files
6. Develop the shared, customer, account, transaction, compliance and index modules
7. Configure JPA and the datasource
8. Assemble the application in the digibank-app module
9. Compile, package and deploy the application
10. Test the REST endpoints
11. Implement JUnit tests
12. Implement the Cucumber scenarios
13. Correct any errors until a stable executable version is obtained

### Grading Breakdown (§16)

| Criterion | Weight |
|---|---|
| Environment installation & configuration | 10% |
| Multi-module Maven structure | 15% |
| Business module development | 30% |
| PostgreSQL & WildFly configuration | 15% |
| REST endpoints & application execution | 10% |
| JUnit tests | 10% |
| Cucumber scenarios | 10% |

---

## Status Summary

| Category | Status | Completion |
|---|---|---|
| Multi-module Maven structure | ✅ Done | 100% |
| Parent POM configuration | ⚠️ Partial | 80% |
| digibank-shared module | ✅ Done | 100% |
| digibank-customer module | ✅ Done | 100% |
| digibank-account module | ✅ Done | 100% |
| digibank-transaction module | ✅ Done | 100% |
| digibank-compliance module | ✅ Done (main code only) | 70% |
| digibank-index module | ✅ Done | 100% |
| digibank-app assembly module | ✅ Done | 100% |
| JPA / persistence.xml | ✅ Done | 100% |
| Database init script | ✅ Done | 100% |
| VS Code configuration | ✅ Done | 100% |
| WildFly Maven Plugin config | ❌ Missing | 0% |
| beans.xml CDI descriptors | ❌ Missing | 0% |
| META-INF directories (business modules) | ❌ Missing | 0% |
| Test directories (src/test) | ❌ Missing | 0% |
| JUnit tests | ❌ Missing | 0% |
| Cucumber feature files | ❌ Missing | 0% |
| Cucumber step definitions | ❌ Missing | 0% |
| Cucumber runner | ❌ Missing | 0% |
| Development notes document | ❌ Missing | 0% |

**Overall estimated completion: ~70%**

---

## Detailed Analysis — What IS Done

### 1. Multi-Module Maven Structure (§4)

- ✅ `digibank-parent/pom.xml` — Parent POM with all 7 modules declared
- ✅ Proper `<dependencyManagement>` for Jakarta EE 10.0.0 API
- ✅ Version properties defined: `jakartaee=10.0.0`, `junit=5.10.2`, `cucumber=7.15.0`, `junit.platform=1.10.2`
- ✅ `maven-compiler-plugin` 3.11.0 and `maven-war-plugin` 3.4.0 in pluginManagement
- ✅ All 7 module directories exist with correct naming

### 2. digibank-shared Module (§5.1)

- ✅ `pom.xml` — `jar` packaging, depends on Jakarta EE (provided)
- ✅ `BaseEntity.java` — `@MappedSuperclass` with `@Id` and `@GeneratedValue(IDENTITY)`
- ✅ `ApiResponse.java` — Shared DTO with `message` and `success` fields, getters/setters

### 3. digibank-customer Module (§5.2) — Full Stack Implementation

- ✅ `pom.xml` — depends on `digibank-shared` + Jakarta EE
- ✅ `Customer.java` — `@Entity`, `@Table("customers")`, extends `BaseEntity`, fields: firstName, lastName, email
- ✅ `CustomerRepository.java` — `@Stateless` EJB, `@PersistenceContext(unitName="digibankPU")`, methods: save, findById, findAll
- ✅ `CustomerService.java` — `@Stateless`, `@Inject` repository, methods: createCustomer, getCustomer, getAllCustomers
- ✅ `CustomerResource.java` — `@Path("/customers")`, `@Consumes`/`@Produces` JSON, endpoints: POST create, GET /{id}, GET all

### 4. digibank-account Module (§5.3)

- ✅ `pom.xml` — depends on `digibank-shared` + Jakarta EE
- ✅ `Account.java` — `@Entity`, `@Table("accounts")`, extends `BaseEntity`, fields: accountNumber (unique), balance
- ✅ `AccountService.java` — `@Stateless`, **in-memory `ArrayList` store** (as per lab spec for simplified version)
- ✅ `AccountResource.java` — `@Path("/accounts")`, endpoints: POST create, GET all

### 5. digibank-transaction Module (§5.4)

- ✅ `pom.xml` — depends on `digibank-shared` + Jakarta EE
- ✅ `Transaction.java` — `@Entity`, `@Table("transactions")`, extends `BaseEntity`, fields: type, amount
- ✅ `TransactionService.java` — `@Stateless`, in-memory `ArrayList` store
- ✅ `TransactionResource.java` — `@Path("/transactions")`, endpoints: POST create, GET all

### 6. digibank-compliance Module (§5.5) — Main Code Only

- ✅ `pom.xml` — depends on Jakarta EE (provided)
- ✅ `ComplianceService.java` — `@Stateless`, validates `amount != null && amount <= 10000`
- ✅ `ComplianceResource.java` — `@Path("/compliance")`, GET `/validate/{amount}`, returns JSON `{"valid":true/false}`

### 7. digibank-index Module (§5.6)

- ✅ `pom.xml` — `war` packaging, `finalName=digibank-index`
- ✅ `IndexServlet.java` — `@WebServlet(urlPatterns={"/", "/index"})`, forwards to `/index.jsp`
- ✅ `index.jsp` — Styled landing page with module list, API endpoint info, footer

### 8. digibank-app Assembly Module (§7)

- ✅ `pom.xml` — `war` packaging, depends on all 6 modules, `maven-war-plugin` with `digibank-index` overlay
- ✅ `DigiBankApplication.java` — `@ApplicationPath("/api")` JAX-RS activation
- ✅ `persistence.xml` — PU name `digibankPU`, JTA transaction type, JNDI `java:/jdbc/DigiBankDS`, schema-generation=update

### 9. Database Init Script (§3)

- ✅ `db/init.sql` — Creates `digibank_db` database, `digibank_user` role with password, grants, collation refresh

### 10. IDE Configuration (§2.2)

- ✅ `.vscode/settings.json` — Java runtimes (JavaSE-17, JavaSE-21), Maven enabled, test working directory
- ✅ `.vscode/extensions.json` — Recommended extensions: Java pack, Maven, Red Hat Java, debugger, test runner, Cucumber

---

## Detailed Analysis — What is NOT Done

### 1. WildFly Maven Plugin (§9.3–9.4) — ❌ MISSING

The lab requires the `wildfly-maven-plugin` for automated deployment:

**In `digibank-parent/pom.xml` (§9.4b)**: A `<pluginManagement>` entry with `skip=true` so only the app module deploys.

**In `digibank-app/pom.xml` (§9.3)**: An active plugin configuration with:
- `skip=false`
- `hostname=localhost`
- `port=9990`
- `username=admin`, `password=admin`
- `filename=digibank-app.war`

> **Impact**: Without this, the `mvn clean install wildfly:deploy` command from §9.4 cannot work. This affects the **PostgreSQL & WildFly configuration (15%)** grade criterion.

### 2. `beans.xml` CDI Descriptors — ❌ MISSING

The lab project tree (§4.1) specifies `src/main/resources/META-INF/` directories inside each business module. These should contain `beans.xml` for CDI bean discovery. Currently **none exist** in any of these modules:

- `digibank-customer/src/main/resources/META-INF/beans.xml`
- `digibank-account/src/main/resources/META-INF/beans.xml`
- `digibank-transaction/src/main/resources/META-INF/beans.xml`
- `digibank-compliance/src/main/resources/META-INF/beans.xml`

> **Impact**: CDI may work implicitly in Jakarta EE 10, but the lab explicitly shows these directories in the tree. Affects **Multi-module Maven structure (15%)**.

### 3. Test Source Directories — ❌ MISSING

**No `src/test/` directories exist at all** in any module. The lab tree structure (§4.1) requires:

- `digibank-shared/src/test/java/com/digibank/shared/`
- `digibank-customer/src/test/java/com/digibank/customer/`
- `digibank-account/src/test/java/com/digibank/account/`
- `digibank-transaction/src/test/java/com/digibank/transaction/`
- `digibank-compliance/src/test/java/com/digibank/compliance/`
- `digibank-index/src/test/java/com/digibank/index/`

> **Impact**: Affects **Multi-module Maven structure (15%)** — tree consistency is an evaluation criterion.

### 4. JUnit Unit Tests (§11) — ❌ MISSING — 10% OF GRADE

**Zero test files exist anywhere in the project.** The lab requires:

- `ComplianceServiceTest.java` in `digibank-compliance` with:
  - `shouldAcceptAmountBelowLimit()` — asserts `validateTransactionAmount(5000.0)` returns `true`
  - `shouldRejectAmountAboveLimit()` — asserts `validateTransactionAmount(20000.0)` returns `false`
- JUnit Jupiter test dependency added to the compliance module POM

> **Impact**: **JUnit tests (10%)** criterion is worth 10% of the grade and is completely unsatisfied.

### 5. Cucumber BDD Scenarios (§12) — ❌ MISSING — 10% OF GRADE

**Completely absent.** The lab requires:

- **Feature file**: `src/test/resources/features/compliance.feature` with 2 scenarios
- **Step definitions**: `ComplianceSteps.java` with `@Given`, `@When`, `@Then` annotated methods
- **Suite runner**: `RunCucumberTest.java` with `@Suite`, `@IncludeEngines("cucumber")`, `@SelectClasspathResource("features")`
- **Maven dependencies**: `cucumber-java`, `cucumber-junit-platform-engine`, `junit-platform-suite-api` in compliance POM

> **Impact**: **Cucumber scenarios (10%)** criterion is worth 10% of the grade and is completely unsatisfied.

### 6. Development Notes Document (§14, item 9) — ❌ MISSING

The lab deliverables include:
> "A short note explaining the order of development followed and the main difficulties encountered."

This document has not been created.

> **Impact**: Part of the required deliverables for submission.

---

## Risk Summary

| Risk Level | Items | Grade at Risk |
|---|---|---|
| 🔴 Critical | JUnit tests entirely missing | 10% |
| 🔴 Critical | Cucumber scenarios entirely missing | 10% |
| 🟡 High | WildFly Maven plugin config missing | Part of 15% |
| 🟡 High | beans.xml + test directories missing | Part of 15% |
| 🟢 Medium | Development notes document | Deliverable completeness |

> **Bottom line**: The project is ~70% complete. The missing testing infrastructure alone accounts for **20% of the grade**.
