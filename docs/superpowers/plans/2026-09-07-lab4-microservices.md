# Lab 4 Microservices Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a complete Digi Bank Lab 4 Spring Boot microservices architecture beside the existing Lab 2 Jakarta EE monolith.

**Architecture:** Add a new `digibank-microservices/` Maven reactor with standalone Spring Boot services. The system uses Spring Cloud Gateway as the single entry point, Eureka for discovery, Spring Cloud Config for centralized configuration, PostgreSQL per business service, Resilience4j for protected service calls, a transfer Saga in the transaction service, CQRS-style command/query separation for transaction reads and writes, Docker Compose orchestration, and GitHub Actions validation.

**Tech Stack:** Java 17, Maven, Spring Boot 3.4.0, Spring Cloud 2024.0.1, Spring Web, Spring Data JPA, PostgreSQL, Eureka, Spring Cloud Gateway, Spring Cloud Config, OpenFeign, Resilience4j, JUnit 5, Docker, Docker Compose, GitHub Actions.

**Spec:** `/home/jude/digibank-cloud-architecture-lab2/UCC122-1_ Cloud architecture Lab 4 EN.pdf`

## Global Constraints

- Keep the existing Lab 2 Jakarta EE/WildFly project unchanged.
- Build Lab 4 under `digibank-microservices/`.
- Use Java 17.
- Use Spring Boot `3.4.0`.
- Use Spring Cloud `2024.0.1`.
- Services required: `api-gateway`, `discovery-server`, `config-server`, `customer-service`, `account-service`, `transaction-service`, `compliance-service`, `notification-service`.
- Each business service owns its own PostgreSQL database.
- Expose consistent REST APIs through each service and route them through the gateway.
- Include Dockerfiles, `docker-compose.yml`, GitHub Actions CI, tests, and documentation.

---

## File Structure

- Create `digibank-microservices/pom.xml`: parent Maven reactor and dependency management.
- Create `digibank-microservices/discovery-server/`: Eureka registry.
- Create `digibank-microservices/config-server/`: Spring Cloud Config server using native local config.
- Create `digibank-microservices/config-repo/*.yml`: central service configuration files.
- Create `digibank-microservices/api-gateway/`: Spring Cloud Gateway routes.
- Create `digibank-microservices/customer-service/`: customer entity, repository, service, controller, tests.
- Create `digibank-microservices/account-service/`: account entity, repository, service, controller, debit/credit endpoints, tests.
- Create `digibank-microservices/compliance-service/`: compliance validation service, controller, tests.
- Create `digibank-microservices/notification-service/`: notification entity, repository, service, controller, tests.
- Create `digibank-microservices/transaction-service/`: transaction entity, command/query handlers, Feign clients, Saga service, controller, tests.
- Create `digibank-microservices/docker-compose.yml`: infrastructure, databases, and services.
- Create `digibank-microservices/docs/lab4-microservices-architecture.md`: architecture, execution notes, endpoint guide, patterns, and deliverable coverage.
- Create `.github/workflows/lab4-microservices-ci.yml`: CI build and tests for the Lab 4 reactor.
- Modify `README.md`: link to the Lab 4 microservices documentation.

## Task 1: Maven Reactor and Infrastructure Services

**Files:**
- Create: `digibank-microservices/pom.xml`
- Create: `digibank-microservices/discovery-server/pom.xml`
- Create: `digibank-microservices/discovery-server/src/main/java/com/digibank/discovery/DiscoveryServerApplication.java`
- Create: `digibank-microservices/discovery-server/src/main/resources/application.yml`
- Create: `digibank-microservices/config-server/pom.xml`
- Create: `digibank-microservices/config-server/src/main/java/com/digibank/config/ConfigServerApplication.java`
- Create: `digibank-microservices/config-server/src/main/resources/application.yml`
- Create: `digibank-microservices/config-repo/application.yml`

**Interfaces:**
- Produces: Eureka registry at `http://localhost:8761`.
- Produces: Config server at `http://localhost:8888`.

- [ ] **Step 1: Write parent and service POMs**

Use a Spring Boot parent reactor with modules for all services. Import `spring-cloud-dependencies` version `2024.0.1`.

- [ ] **Step 2: Add discovery application**

Create `DiscoveryServerApplication` with `@SpringBootApplication` and `@EnableEurekaServer`.

- [ ] **Step 3: Add config application**

Create `ConfigServerApplication` with `@SpringBootApplication` and `@EnableConfigServer`.

- [ ] **Step 4: Verify infrastructure compile**

Run: `mvn -f digibank-microservices/pom.xml -pl discovery-server,config-server test`

Expected: both modules compile with zero test failures.

## Task 2: Customer, Account, Compliance, and Notification Services

**Files:**
- Create business service POM, `Application.java`, `application.yml`, model, repository, service, controller, and service tests for `customer-service`, `account-service`, `compliance-service`, and `notification-service`.

**Interfaces:**
- Produces: `POST /customers`, `GET /customers`, `GET /customers/{id}`.
- Produces: `POST /accounts`, `GET /accounts`, `GET /accounts/{id}`, `POST /accounts/{id}/debit`, `POST /accounts/{id}/credit`.
- Produces: `GET /compliance/validate/{amount}` returning `{"valid": true|false}`.
- Produces: `POST /notifications`, `GET /notifications`.

- [ ] **Step 1: Write failing service tests**

Add tests for customer creation, account credit/debit validation, compliance limits, and notification recording.

- [ ] **Step 2: Verify tests fail before implementation**

Run each module test before adding production code.

- [ ] **Step 3: Implement minimal service code**

Implement entities, repositories, services, controllers, and request DTOs.

- [ ] **Step 4: Verify tests pass**

Run: `mvn -f digibank-microservices/pom.xml -pl customer-service,account-service,compliance-service,notification-service test`

Expected: all four service modules pass.

## Task 3: Transaction Service with Feign, Circuit Breaker, Saga, and CQRS

**Files:**
- Create: `digibank-microservices/transaction-service/pom.xml`
- Create: `TransactionServiceApplication.java`
- Create: `model/Transaction.java`
- Create: `repository/TransactionRepository.java`
- Create: `command/CreateTransactionCommand.java`
- Create: `command/TransactionCommandHandler.java`
- Create: `query/TransactionView.java`
- Create: `query/TransactionQueryService.java`
- Create: `client/ComplianceClient.java`
- Create: `client/AccountClient.java`
- Create: `client/NotificationClient.java`
- Create: `service/TransferSagaService.java`
- Create: `api/TransactionController.java`
- Create: service tests for command/query and Saga fallback behavior.

**Interfaces:**
- Consumes: compliance `GET /compliance/validate/{amount}`.
- Consumes: account `POST /accounts/{id}/debit` and `POST /accounts/{id}/credit`.
- Consumes: notification `POST /notifications`.
- Produces: `POST /transactions`, `GET /transactions`, `POST /transactions/transfers`.

- [ ] **Step 1: Write failing transaction tests**

Test that invalid compliance rejects a transaction, command handler stores approved transactions, query service returns read views, and Saga compensates debit if credit fails.

- [ ] **Step 2: Verify tests fail before implementation**

Run: `mvn -f digibank-microservices/pom.xml -pl transaction-service test`

- [ ] **Step 3: Implement Feign clients and Circuit Breaker wrappers**

Use OpenFeign clients and `@CircuitBreaker` around service methods that depend on compliance, account, and notification services.

- [ ] **Step 4: Implement Saga and CQRS classes**

Keep transfer orchestration in `TransferSagaService`, writes in `TransactionCommandHandler`, and reads in `TransactionQueryService`.

- [ ] **Step 5: Verify transaction tests pass**

Run: `mvn -f digibank-microservices/pom.xml -pl transaction-service test`

Expected: all transaction-service tests pass.

## Task 4: Gateway, Central Configuration, Docker, CI, and Docs

**Files:**
- Create: `api-gateway` module with gateway routes.
- Create: `config-repo/*.yml` for each service.
- Create: one `Dockerfile` per component.
- Create: `digibank-microservices/docker-compose.yml`.
- Create: `.github/workflows/lab4-microservices-ci.yml`.
- Create: `digibank-microservices/docs/lab4-microservices-architecture.md`.
- Modify: `README.md`.

**Interfaces:**
- Produces: gateway route `/api/customers/**` to customer service.
- Produces: gateway route `/api/accounts/**` to account service.
- Produces: gateway route `/api/transactions/**` to transaction service.
- Produces: gateway route `/api/compliance/**` to compliance service.
- Produces: gateway route `/api/notifications/**` to notification service.

- [ ] **Step 1: Add gateway route configuration**

Configure Spring Cloud Gateway with logical service names and Eureka discovery.

- [ ] **Step 2: Add Dockerfiles and Compose orchestration**

Define PostgreSQL containers, config server, discovery server, gateway, and business services with health-aware dependencies where possible.

- [ ] **Step 3: Add CI workflow**

Run `mvn -f digibank-microservices/pom.xml test` on pushes and pull requests.

- [ ] **Step 4: Add documentation**

Document architecture diagrams, service responsibilities, ports, endpoints, patterns, Docker commands, CI, tests, and deliverable coverage.

- [ ] **Step 5: Verify full Lab 4 build**

Run: `mvn -f digibank-microservices/pom.xml test`

Expected: all modules compile and test successfully.

## Self-Review

- Spec coverage: tasks cover services, databases, Eureka, config server, gateway, circuit breaker, Saga, CQRS, Docker, Docker Compose, GitHub Actions, tests, and documentation.
- Placeholder scan: no implementation task relies on an undefined future placeholder.
- Type consistency: planned services use Spring Boot package roots under `com.digibank.<service>`, REST APIs use plural resource paths, and transaction clients consume the endpoints produced by business services.
