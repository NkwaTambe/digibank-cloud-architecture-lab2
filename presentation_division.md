# Digi Bank Cloud Architecture - Presentation Team Division & Script

This document details the slide division, domain assignments, and key speaking notes for all 5 team members to ensure balanced, highly professional participation during the presentation.

---

## 👥 Team Overview & Presentation Schedule

| Presenter # | Team Member | Assigned Slides | Primary Topic & Domain Focus |
| :--- | :--- | :---: | :--- |
| **Presenter 1** | **Nancy Muneh** | **Slides 1 – 8** | Project Overview, Architecture Blueprint & Lab 1 Requirements |
| **Presenter 2** | **Ful Valentine** | **Slides 9 – 14a** | Lab 2 Jakarta EE 10 Enterprise Monolith Core, EJBs & Standards |
| **Presenter 3** | **Tchikaya Ariel** | **Slides 15a – 20** | Lab 2 DevOps, Docker Infrastructure, Solved Issues & Lab 3 Intro |
| **Presenter 4** | **Nkwa Jude** | **Slides 21 – 29** | Lab 3 Spring Ecosystem, OpenAPI, BDD Testing & Solved Challenges |
| **Presenter 5** | **Bryan Dino** | **Slides 30 – 42** | Lab 4 Cloud-Native Microservices, Sagas, Comparison & Conclusion |

---

## 🎙️ Detailed Slide-by-Slide Speaker Breakdown

### 🟢 PART 1: Project Overview & Lab 1 Requirements Foundation
**Speaker**: **Nancy Muneh** (Slides 1 – 8)

* **Slide 1 (Title Slide)**: Welcome the committee and supervisor (Eng. Willy Damtchou). Introduce the Digi Bank project topic: *From Modular Monoliths to Cloud-Native Microservices*. Introduce the 5 team members.
* **Slide 2 (Project Engineering Team)**: Present the engineering roles: Cloud Architecture, Jakarta EE, DevOps, Spring Ecosystem, and Microservices/Sagas.
* **Slide 3 (Architectural Progression Roadmap)**: Outline the 4-phase lab progression: Lab 1 Blueprinting -> Lab 2 Jakarta EE Monolith -> Lab 3 Spring Boot Migration -> Lab 4 Microservices Ecosystem.
* **Slide 4 (Lab 1 Title)**: Transition into Part 1: Architecture Foundation.
* **Slide 5 (Lab 1 Objectives & Scope)**: Explain domain boundaries, business entities, and initial functional/non-functional constraints.
* **Slide 6 (Stakeholder Matrix)**: Detail the interests and architectural impacts for Bank Customers, Compliance Officers, System Admins, and DevOps.
* **Slide 7 (System Functions & Constraints)**: Cover core banking operations (Deposits, Transfers, Compliance limit &le; $10k) and non-functional goals (99.9% uptime, relational ACID guarantees).
* **Slide 8 (Target Monolith Architecture Blueprint)**: Explain the initial target modular monolith design bundling Customer, Account, Transaction, and Compliance under `digibank-shared` on PostgreSQL.

> 🔄 **Handover Transition to Ful Valentine**: 
> *"Now that we have established the foundational requirements and initial architecture blueprint, I hand over to Ful Valentine to present our Lab 2 enterprise implementation using Jakarta EE 10."*

---

### 🔵 PART 2: Lab 2 Enterprise EE Containerized Monolith Core
**Speaker**: **Ful Valentine** (Slides 9 – 14a)

* **Slide 9 (Lab 2 Title)**: Introduce Lab 2: Enterprise Java Standards, WildFly 33 application server, and containerized PostgreSQL deployment.
* **Slide 10 (Lab 2 Enterprise Tech Stack)**: Detail Java 17, Jakarta EE 10 specifications (CDI 4.0, EJB 4.0, JPA 3.1, JAX-RS), WildFly 33, and JNDI Datasource configuration (`java:/jdbc/DigiBankDS`).
* **Slide 11 (7 Maven Reactor Modules)**: Walk through the reactor structure: `digibank-shared`, `digibank-customer`, `digibank-account`, `digibank-transaction`, `digibank-compliance`, `digibank-index`, and `digibank-app`.
* **Slide 12 (Enterprise Design Patterns)**: Highlight `@Stateless` session EJBs for container-managed transactions (CMT) and `@Inject` for CDI dependency injection.
* **Slide 13a (Interactive API Documentation)**: Explain Swagger UI integration via `microprofile-openapi` exposed at `/swagger-ui.html`.
* **Slide 14a (Testing Strategy & BDD Automation)**: Explain unit testing with JUnit 5, integration testing with Arquillian on WildFly, and BDD scenario validation using Cucumber.

> 🔄 **Handover Transition to Tchikaya Ariel**: 
> *"To walk us through the container orchestration infrastructure, build automation scripts, and real-world enterprise deployment challenges of Lab 2, I pass the microphone to Tchikaya Ariel."*

---

### 🟡 PART 3: Lab 2 Infrastructure, Solved Challenges & Lab 3 Overview
**Speaker**: **Tchikaya Ariel** (Slides 15a – 20)

* **Slide 15a (Co-existence Infrastructure)**: Explain the `docker-compose.yml` setup combining WildFly 33 and PostgreSQL 17 on isolated host port 5434.
* **Slide 16a (Automation & Orchestration Script - setup.sh)**: Describe the automated shell script that executes `mvn clean install`, launches Docker containers, deploys the WAR, and runs live smoke tests.
* **Slide 17a (Real-world Challenges & Solutions)**: Discuss key technical hurdles overcome in Lab 2: Class-loader conflicts on WildFly, Flyway schema ordering, EJB CMT vs CDI transactional boundary bugs, and Swagger UI activation.
* **Slide 13 (Lab 3 Title - Spring Migration)**: Transition into Part 3: Porting the monolith to the Spring ecosystem.
* **Slide 14 (Lab 3 Goal & Architectural Purpose)**: Rebuilding the exact same 7-module monolith using Spring Boot 3.5 to prove 100% functional equivalence and enterprise framework portability.
* **Slide 15 (Lab 3 Technology Stack)**: Present Spring Boot 3.5.15, Spring Data JPA, Thymeleaf UI, Springdoc OpenAPI 2.8.17, and PostgreSQL 16 on port 5435.
* **Slide 16 (Reactor Module Breakdown - digibank-parent-spring)**: Map out how each module was migrated to Spring (`JpaRepository`, `@Service`, `@RestController`, `IndexController`).
* **Slide 17 (Enterprise Spring Patterns)**: Detail `Spring Data JPA` repositories and `@Transactional` declarative ACID boundaries.
* **Slide 18 (Multi-Module Component Scanning Configuration)**: Explain cross-module bean discovery using `@ComponentScan`, `@EntityScan`, and `@EnableJpaRepositories`.
* **Slide 19 (Lab 3 Data Model & Mapping)**: Explain physical table schemas (`snake_case`) and `@MappedSuperclass` inheritance from `BaseEntity`.
* **Slide 20 (REST API Endpoint Catalog)**: Walk through customer, account, transaction, and compliance endpoints under `/digibank-app/api`.

> 🔄 **Handover Transition to Nkwa Jude**: 
> *"Now I turn over to Nkwa Jude, who will explain our Spring OpenAPI integration, BDD quality assurance, coexistence scripts, and the critical technical challenges solved in Lab 3."*

---

### 🟣 PART 4: Lab 3 Spring Ecosystem & Solved Challenges
**Speaker**: **Nkwa Jude** (Slides 21 – 29)

* **Slide 21 (Interactive API Documentation - Springdoc)**: Explain automated OpenAPI 3.0 generation and live testing at `http://localhost:9091/digibank-app/swagger-ui.html`.
* **Slide 22 (Testing Strategy & BDD Automation)**: Cover JUnit 5 threshold testing ($5k, $10k, $20k), Gherkin scenarios with Cucumber, and static code quality gates (`mvn verify`).
* **Slide 23 (Coexistence Infrastructure - docker-compose.spring.yml)**: Highlight collision-free coexistence running alongside Lab 2 (PostgreSQL port 5435, WildFly port 9091, Adminer port 8083).
* **Slide 24 (Automation & Orchestration Script - setup-spring.sh)**: Explain single-command deployment (`./setup-spring.sh docker`) and cURL verification.
* **Slide 25 (Challenge 1: Multi-Module Component Scanning)**: Explain resolving missing bean discovery across sibling modules using explicit package scanning annotations.
* **Slide 26 (Challenge 2: @PathVariable Reflection Name Resolution)**: Explain fixing HTTP 500 byte-code errors on WildFly using compiler `<parameters>true</parameters>`.
* **Slide 27 (Challenge 3: Column Naming Strategy Mismatch)**: Explain resolving camelCase vs snake_case schema conflicts between Lab 2 SQL and Hibernate 6.
* **Slide 28 (Challenge 4: External WAR Deployment on WildFly)**: Detail configuring `<scope>provided</scope>` for Tomcat starter dependencies and extending `SpringBootServletInitializer`.
* **Slide 29 (Challenge 5: Idempotent REST Script Testing)**: Describe adding dynamic epoch timestamps (`$(date +%s)`) to cURL payloads to prevent duplicate key database violations.

> 🔄 **Handover Transition to Bryan Dino**: 
> *"To conclude our presentation, Bryan Dino will guide us through Lab 4: our Cloud-Native Microservices decomposition, API Gateway, Eureka discovery, Saga transactions, and our final comparative synthesis."*

---

### 🔴 PART 5: Lab 4 Cloud-Native Microservices, Sagas & Conclusion
**Speaker**: **Bryan Dino** (Slides 30 – 42)

* **Slide 30 (Lab 4 Title - Microservices Architecture)**: Introduce Lab 4: Cloud-native decomposition and distributed architecture.
* **Slide 31 (Why Decompose the Monolith?)**: Present the 4 architectural drivers: Independent scalability, fault isolation, database-per-service, and autonomous deployment cycles.
* **Slide 32 (Microservices Ecosystem Inventory)**: Detail the 8 autonomous services (`api-gateway`, `discovery-server`, `config-server`, `customer-service`, `account-service`, `transaction-service`, `compliance-service`, `notification-service`).
* **Slide 33 (Discovery & API Gateway Integration)**: Explain dynamic registration with Eureka (port 8761) and unified routing via Spring Cloud Gateway (port 8080).
* **Slide 34 (Fault Tolerance & Resilience4j)**: Explain Circuit Breakers (CLOSED, OPEN, HALF-OPEN) and fallback mechanisms to isolate remote RPC failures.
* **Slide 35 (Distributed Saga Orchestration Flow)**: Walk through the 3-step transaction saga (Compliance Check -> Debit Source -> Credit Target) and automated compensating refund events if credit fails.
* **Slide 36 (CQRS Pattern Implementation)**: Explain separating write commands (`TransactionCommandHandler`) from high-volume read queries (`TransactionQueryService`).
* **Slide 37 (Lab 4 Docker Orchestration Grid)**: Present the 13-container grid (8 microservices + 5 dedicated PostgreSQL DB containers).
* **Slide 38 (Architectural Comparison: EE vs Spring vs Cloud)**: Compare Lab 2, Lab 3, and Lab 4 across Dependency Injection, Data Access, Deployment, and Service Discovery.
* **Slide 39 (Progression Synthesis Across Labs)**: Summarize the complete evolutionary path from initial design to cloud-native maturity.
* **Slide 40 (Key Engineering Lessons Learned)**: Share insights on domain boundaries, framework interoperability, distributed resilience, and non-negotiable DevOps automation.
* **Slide 41 (Conclusion)**: Conclude with the successful completion of the Digi Bank architectural modernization roadmap.
* **Slide 42 (Q&A & Discussion)**: Open the floor to questions from supervisor Eng. Willy Damtchou and the evaluation panel.
