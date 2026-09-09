# DigiBank Quick Start

This is the simple startup guide for the whole repository.

Use this file when you want to quickly run one version of the project and know which browser pages to open for the demo.

---

## 1. Start the Lab 2 Jakarta EE / WildFly App

This is the main Lab 2 version.

It is a modular monolith built with Jakarta EE and deployed on WildFly.

From the repository root:

```bash
./setup.sh
```

Choose:

```text
1
```

This starts:

- PostgreSQL database
- WildFly application server
- DigiBank web application
- Adminer database web tool

Open these pages:

| Page | URL |
|---|---|
| DigiBank app | http://localhost:9090/digibank-app |
| Swagger UI | http://localhost:9090/digibank-app/swagger.html |
| API base | http://localhost:9090/digibank-app/api/ |
| Adminer database UI | http://localhost:8082 |

Adminer login:

| Field | Value |
|---|---|
| System | PostgreSQL |
| Server | db |
| Username | digibank_user |
| Password | digibank_pwd |
| Database | digibank_db |

To stop it:

```bash
./setup.sh
```

Choose:

```text
2
```

---

## 2. Start the Spring Boot Monolith

This is the Spring Boot version of the modular monolith.

From the repository root:

```bash
./setup-spring.sh
```

Choose:

```text
1
```

This starts:

- PostgreSQL database
- WildFly application server
- Spring-based DigiBank application
- Adminer database web tool

Open these pages:

| Page | URL |
|---|---|
| Spring DigiBank app | http://localhost:9091/digibank-app |
| Swagger UI | http://localhost:9091/digibank-app/swagger-ui.html |
| API base | http://localhost:9091/digibank-app/api/ |
| Adminer database UI | http://localhost:8083 |

Adminer login:

| Field | Value |
|---|---|
| System | PostgreSQL |
| Server | db |
| Username | digibank_user |
| Password | digibank_pwd |
| Database | digibank_db |

To stop it:

```bash
./setup-spring.sh
```

Choose:

```text
2
```

---

## 3. Start the Lab 4 Microservices App

This is the distributed microservices version.

It has separate services for customers, accounts, transactions, compliance, and notifications.

First build the service JAR files:

```bash
mvn -f digibank-microservices/pom.xml clean package
```

Then start Docker Compose:

```bash
cd digibank-microservices
docker compose up --build
```

This starts:

- API Gateway
- Eureka discovery server
- Config server
- Customer service
- Account service
- Transaction service
- Compliance service
- Notification service
- One PostgreSQL database per business service

Open these pages:

| Page | URL |
|---|---|
| Microservices portal / API Gateway | http://localhost:8080 |
| Eureka dashboard | http://localhost:8761 |
| Config server | http://localhost:8888 |
| Customer service Swagger | http://localhost:8081/swagger-ui.html |
| Account service Swagger | http://localhost:8082/swagger-ui.html |
| Transaction service Swagger | http://localhost:8083/swagger-ui.html |
| Compliance service Swagger | http://localhost:8084/swagger-ui.html |
| Notification service Swagger | http://localhost:8085/swagger-ui.html |

Useful direct service URLs:

| Service | URL |
|---|---|
| Customers | http://localhost:8081/customers |
| Accounts | http://localhost:8082/accounts |
| Transactions | http://localhost:8083/transactions |
| Compliance check | http://localhost:8084/compliance/validate/5000 |
| Notifications | http://localhost:8085/notifications |

Useful gateway URLs:

| Action | URL |
|---|---|
| Customers through gateway | http://localhost:8080/api/customers |
| Accounts through gateway | http://localhost:8080/api/accounts |
| Transactions through gateway | http://localhost:8080/api/transactions |
| Compliance through gateway | http://localhost:8080/api/compliance/validate/5000 |
| Notifications through gateway | http://localhost:8080/api/notifications |

To stop it:

```bash
docker compose down
```

If you are not inside the microservices folder:

```bash
cd digibank-microservices
docker compose down
```

---

## 4. Run Tests

Run Lab 2 tests:

```bash
mvn -f digibank-parent/pom.xml test
```

Run Spring monolith tests:

```bash
mvn -f digibank-parent-spring/pom.xml test
```

Run microservices tests:

```bash
mvn -f digibank-microservices/pom.xml test
```

---

## 5. Which Version Should We Demo?

For a simple presentation, demo in this order:

1. Start with the Lab 2 Jakarta EE app.
2. Show the DigiBank app page.
3. Open Swagger and test one API.
4. Open Adminer and show the database.
5. Then explain that Lab 4 evolves the same banking idea into microservices.
6. Open the microservices portal, Eureka dashboard, and one Swagger page.

Short explanation:

> The project begins as one banking application, then evolves into multiple independent services. The first version is easier to deploy as one unit. The microservices version is better for scaling, separating responsibilities, and showing cloud architecture patterns like service discovery, API gateway, centralized configuration, and database per service.

