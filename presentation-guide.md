# DigiBank Presentation Guide

Use this guide to explain the project in simple language during the presentation.

---

## 1. What Is DigiBank?

DigiBank is a small banking system built for the Cloud Architecture lab.

It shows how a banking application can manage:

- customers
- bank accounts
- transactions
- compliance checks
- notifications

The project is not a real bank application for production. It is a learning project that demonstrates architecture, APIs, databases, testing, Docker, CI/CD, and microservices.

---

## 2. What Is Inside the Repository?

The repository contains three versions of the same banking idea.

| Folder | Meaning |
|---|---|
| `digibank-parent` | Lab 2 Jakarta EE / WildFly modular monolith |
| `digibank-parent-spring` | Spring Boot modular monolith |
| `digibank-microservices` | Lab 4 Spring Cloud microservices version |

Simple explanation:

> We started with one application, then created a Spring version, then evolved the same banking system into microservices.

---

## 3. The Lab 2 Jakarta EE Version

The Lab 2 version is in:

```text
digibank-parent
```

It is a modular monolith.

That means the code is separated into modules, but the final application is deployed as one application.

The modules are:

| Module | Role |
|---|---|
| `digibank-shared` | Common classes used by other modules |
| `digibank-customer` | Customer management |
| `digibank-account` | Bank account management |
| `digibank-transaction` | Transaction management |
| `digibank-compliance` | Checks whether transaction amounts are allowed |
| `digibank-index` | Web landing page |
| `digibank-app` | Final WAR application that combines all modules |

The strongest proof that it is a monolith is that all modules are packaged into one file:

```text
digibank-app.war
```

Presentation sentence:

> In the Jakarta EE version, customer, account, transaction, and compliance are separated in code, but they are deployed together as one WAR file on WildFly.

---

## 4. The Spring Boot Monolith

The Spring version is in:

```text
digibank-parent-spring
```

It keeps the same modular idea but uses Spring Boot instead of Jakarta EE.

In Jakarta EE, WildFly manages the application.

In Spring Boot, Spring manages the application.

Presentation sentence:

> The Spring version shows the same banking system implemented with Spring Boot annotations like `@SpringBootApplication`, `@RestController`, `@Service`, and `JpaRepository`.

---

## 5. The Lab 4 Microservices Version

The microservices version is in:

```text
digibank-microservices
```

This version splits the banking system into separate applications.

| Service | Role |
|---|---|
| `api-gateway` | Single entry point for clients |
| `discovery-server` | Eureka service registry |
| `config-server` | Central configuration server |
| `customer-service` | Manages customers |
| `account-service` | Manages accounts and balances |
| `transaction-service` | Handles transactions and transfers |
| `compliance-service` | Validates transaction amounts |
| `notification-service` | Stores/sends business notifications |

Each business service has its own database.

Presentation sentence:

> In the microservices version, each business area becomes its own application, with its own port, database, Docker container, and Swagger page.

---

## 6. Main Difference: Monolith vs Microservices

| Topic | Modular Monolith | Microservices |
|---|---|---|
| Deployment | One application | Many applications |
| Runtime | One server hosts the app | Each service runs separately |
| Database | Shared database connection | Database per service |
| Communication | Modules call code inside one app | Services communicate over HTTP |
| Scaling | Scale the whole app | Scale individual services |
| Complexity | Easier to start | More cloud-ready but more complex |

Simple answer:

> A monolith is one deployable application. Microservices are many small deployable applications working together.

---

## 7. Important Cloud Architecture Concepts

### API Gateway

The API Gateway is the front door of the microservices system.

Instead of clients calling every service directly, they call the gateway.

Example:

```text
http://localhost:8080/api/customers
```

The gateway sends that request to `customer-service`.

### Eureka Discovery Server

Eureka is like a service phonebook.

Services register themselves there, and other services can find them.

This matters because in cloud systems, service locations can change.

### Config Server

The Config Server stores configuration in one central place.

Instead of putting all configuration separately inside every service, services can read configuration from the config server.

### Database Per Service

Each microservice owns its own data.

For example:

- customer service owns customer data
- account service owns account data
- transaction service owns transaction data

This keeps services independent.

### Swagger

Swagger is a web page for testing and documenting APIs.

It lets us see endpoints and test them in the browser.

### Docker Compose

Docker Compose starts many containers together.

For this project, it can start databases, WildFly, gateway, discovery server, config server, and microservices.

---

## 8. How We Demo the Project

Recommended order:

1. Open `quick-start.md`.
2. Start the Lab 2 Jakarta EE app.
3. Show the DigiBank landing page.
4. Open Swagger and test one endpoint.
5. Open Adminer and show the database.
6. Explain that this is the modular monolith.
7. Start or explain the microservices version.
8. Open the API Gateway page.
9. Open Eureka dashboard.
10. Open one service Swagger page.

Short demo explanation:

> First, we show the application running as one deployable system. Then we show how the same idea can evolve into independent cloud services.

---

## 9. What We Tested

The project includes automated tests.

Examples:

- account service tests
- transaction service tests
- compliance service tests
- Cucumber BDD compliance scenarios
- microservice unit tests

Important compliance rule:

> A transaction amount must be less than or equal to 10,000.

Presentation sentence:

> We used JUnit for technical unit tests and Cucumber for business-readable test scenarios.

---

## 10. What CI/CD Means in This Project

CI/CD means the project can be checked automatically when code is pushed to GitHub.

This repository has GitHub Actions workflows that:

- check out the code
- install Java 17
- build the Maven projects
- run tests
- run Checkstyle
- run PMD
- upload test and quality reports
- check Docker build configuration

Presentation sentence:

> CI/CD helps us prove that the project still builds and passes tests after code changes.

---

## 11. Final Summary

DigiBank demonstrates the evolution of a banking application.

First, it is built as a modular monolith with Jakarta EE and WildFly.

Then, it is also implemented with Spring Boot.

Finally, it is decomposed into microservices using Spring Cloud patterns like API Gateway, Eureka discovery, Config Server, Docker Compose, database per service, Swagger documentation, and automated CI checks.

Final sentence:

> This project shows how a simple banking system can move from one application to a cloud-ready microservices architecture.

