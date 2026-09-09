# Teacher Questions and Answers

Use this file to prepare for questions during the presentation.

---

## 1. What Is This Project About?

**Question:** What is DigiBank?

**Answer:** DigiBank is a banking application built for the Cloud Architecture lab. It manages customers, accounts, transactions, compliance checks, and notifications.

---

## 2. Why Do You Have Three Main Project Folders?

**Question:** Why are there `digibank-parent`, `digibank-parent-spring`, and `digibank-microservices`?

**Answer:** They show the evolution of the same banking system. `digibank-parent` is the Jakarta EE modular monolith. `digibank-parent-spring` is the Spring Boot modular monolith. `digibank-microservices` is the distributed microservices version.

---

## 3. What Is a Modular Monolith?

**Question:** What makes the Lab 2 version a modular monolith?

**Answer:** The code is separated into modules like customer, account, transaction, and compliance, but everything is packaged and deployed as one application called `digibank-app.war`.

**Code proof:** `digibank-parent/digibank-app/pom.xml` has:

```xml
<artifactId>digibank-app</artifactId>
<packaging>war</packaging>
```

---

## 4. What Is a Microservice?

**Question:** What makes the Lab 4 version microservices?

**Answer:** Each business area is a separate Spring Boot application. Customer, account, transaction, compliance, and notification all run as separate services with their own ports and databases.

**Code proof:** `digibank-microservices/docker-compose.yml` defines separate services such as:

```yaml
customer-service
account-service
transaction-service
compliance-service
notification-service
```

---

## 5. Main Difference Between Monolith and Microservices

**Question:** What is the main difference between the monolith and microservices versions?

**Answer:** The monolith is one deployable application. The microservices version is many independent applications working together through the API Gateway and service-to-service communication.

---

## 6. What Is Jakarta EE?

**Question:** What is Jakarta EE used for in this project?

**Answer:** Jakarta EE provides enterprise Java features like REST APIs, dependency injection, EJB services, and JPA persistence. In this project, WildFly runs the Jakarta EE application.

**Code proof:** The Jakarta EE REST class uses:

```java
@Path("/customers")
```

And the service uses:

```java
@Stateless
```

---

## 7. What Is Spring Boot?

**Question:** What is Spring Boot used for in this project?

**Answer:** Spring Boot is used to build the Spring monolith and microservices. It manages controllers, services, repositories, configuration, and application startup.

**Code proof:** Spring applications use:

```java
@SpringBootApplication
```

---

## 8. Jakarta EE vs Spring Boot

**Question:** What is the difference between Jakarta EE and Spring Boot?

**Answer:** In Jakarta EE, the application is deployed into WildFly, and WildFly manages it. In Spring Boot, the application starts with `SpringApplication.run`, and Spring manages the application.

Simple answer:

> Jakarta EE: WildFly runs my app. Spring Boot: my app starts itself using Spring.

---

## 9. What Is WildFly?

**Question:** What is WildFly?

**Answer:** WildFly is an application server. It hosts and runs the Jakarta EE application. It provides runtime services like REST handling, dependency injection, JPA, and database connection management.

---

## 10. What Is PostgreSQL?

**Question:** Why did you use PostgreSQL?

**Answer:** PostgreSQL is the relational database used to store application data like customers, accounts, and transactions.

---

## 11. What Is JPA?

**Question:** What is JPA?

**Answer:** JPA is a Java standard for mapping Java classes to database tables. For example, a `Customer` class can become a `customers` table.

---

## 12. What Is `persistence.xml`?

**Question:** What is the purpose of `persistence.xml`?

**Answer:** It configures JPA for the Jakarta EE version. It defines the persistence unit, database source, and entity classes.

**Code proof:** `digibank-parent/digibank-app/src/main/resources/META-INF/persistence.xml` contains:

```xml
<persistence-unit name="digibankPU">
```

---

## 13. What Is Swagger?

**Question:** Why did you add Swagger?

**Answer:** Swagger documents the REST APIs and lets us test endpoints from a browser.

---

## 14. What Is Docker Compose?

**Question:** What does Docker Compose do here?

**Answer:** Docker Compose starts multiple containers together. In this project, it can start the app, databases, Adminer, and the microservices infrastructure.

---

## 15. What Is Adminer?

**Question:** What is Adminer used for?

**Answer:** Adminer is a browser-based database tool. We use it to view the PostgreSQL database during the demo.

---

## 16. What Is an API Gateway?

**Question:** What is the API Gateway?

**Answer:** The API Gateway is the single entry point for the microservices. Clients call the gateway, and the gateway routes the request to the correct service.

Example:

```text
/api/customers goes to customer-service
```

---

## 17. What Is Eureka?

**Question:** What is Eureka?

**Answer:** Eureka is the discovery server. It is like a phonebook where services register themselves so other services can find them.

---

## 18. What Is the Config Server?

**Question:** Why do you have a Config Server?

**Answer:** The Config Server centralizes configuration for the microservices. This is useful because cloud systems can have many services, and managing configuration in one place is cleaner.

---

## 19. Why Does Each Microservice Have Its Own Database?

**Question:** Why not use one database for all microservices?

**Answer:** In microservices, each service should own its own data. This makes services more independent and easier to change or scale separately.

---

## 20. What Is the Compliance Rule?

**Question:** What business rule does the compliance service check?

**Answer:** It checks whether a transaction amount is allowed. The rule is that the amount must be less than or equal to 10,000.

---

## 21. What Is JUnit?

**Question:** Why did you use JUnit?

**Answer:** JUnit is used for unit tests. It checks individual Java classes and business logic.

---

## 22. What Is Cucumber?

**Question:** Why did you use Cucumber?

**Answer:** Cucumber lets us write tests in business-readable language. It is useful for explaining rules like compliance checks.

Example:

```text
Given a transaction amount of 5000
When the compliance check is performed
Then the transaction is accepted
```

---

## 23. What Is CI/CD?

**Question:** What is CI/CD in your project?

**Answer:** CI/CD means GitHub automatically checks the project when code is pushed. It builds the project, runs tests, runs quality checks, and saves reports.

---

## 24. What Are Checkstyle and PMD?

**Question:** Why do you have Checkstyle and PMD?

**Answer:** Checkstyle checks Java coding style. PMD checks for common code problems. They help keep the code clean and maintainable.

---

## 25. What Was the Hardest Part?

**Question:** What was difficult in this project?

**Answer:** The hardest part was connecting many technologies together: Maven modules, WildFly, PostgreSQL, Docker, tests, CI, and later microservices with gateway, discovery, and config server.

---

## 26. What Would You Improve?

**Question:** What would you improve if you had more time?

**Answer:** I would add stronger security, authentication, better error handling, monitoring, centralized logging, and more integration tests.

---

## 27. Is This Production Ready?

**Question:** Is this ready for real banking production?

**Answer:** No. It is a lab project. A real banking system would need authentication, authorization, encryption, audit logs, monitoring, stronger validation, secure secrets management, and more testing.

---

## 28. How Would You Secure It?

**Question:** How would you protect customer data?

**Answer:** I would add login, role-based access control, HTTPS, encrypted secrets, password policies, input validation, audit logs, and database access restrictions.

---

## 29. How Would You Deploy It in the Cloud?

**Question:** How could this run on AWS, Azure, or GCP?

**Answer:** The Docker containers could be deployed to a container platform like Kubernetes or a managed container service. The databases could use managed PostgreSQL. Logs and metrics could go to cloud monitoring tools.

---

## 30. Final Defense Answer

**Question:** Explain your whole project in one minute.

**Answer:** DigiBank is a banking system created for a cloud architecture lab. We first built it as a Jakarta EE modular monolith deployed on WildFly, where all modules are packaged into one WAR file. Then we created a Spring Boot monolith version. Finally, we evolved the same system into microservices, with separate services for customers, accounts, transactions, compliance, and notifications. The microservices version adds cloud patterns like API Gateway, Eureka service discovery, Config Server, Docker Compose, database per service, Swagger documentation, automated tests, and CI/CD pipelines.

