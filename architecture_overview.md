# Cloud Architecture Overview (Labs 1, 2 & 3)

This document details the architectural evolution of the **DigiBank Banking Platform** across three distinct evolutionary stages:
1. **Lab 1**: Domain-Driven Monolith (Maven Multi-Module Assembly)
2. **Lab 2**: Enterprise EE Containerized Monolith (WildFly 33 & PostgreSQL in Docker)
3. **Lab 3**: Cloud-Native Microservices Ecosystem (Spring Boot, Spring Cloud, Eureka & Docker)

---

## Lab 1: Domain-Driven Monolith Architecture (Maven Reactor)

```mermaid
flowchart TD
    subgraph Client["Presentation Tier"]
        Browser["User Browser / REST Client"]
    end

    subgraph Packaging["Monolithic Web Artifact (digibank-app.war)"]
        WebModule["digibank-index\n(JSP Landing & Servlet Router)"]

        subgraph Modules["Business Domain Modules"]
            CustMod["digibank-customer\n(Customer Entity & Service)"]
            AccMod["digibank-account\n(Account Entity & Service)"]
            TxMod["digibank-transaction\n(Transaction Entity & Service)"]
            CompMod["digibank-compliance\n(Compliance Validation Rules)"]
        end

        SharedMod["digibank-shared\n(BaseEntity, Shared DTOs & Audit)"]
    end

    subgraph DataTier["Persistence Tier"]
        JPA["JPA 3.1 / Hibernate ORM Engine"]
        DB[(Relational DB / H2)]
    end

    Browser -->|HTTP Request| WebModule
    WebModule -->|Direct Java Call| Modules
    Modules -->|Extends & Uses| SharedMod
    Modules -->|ORM Mapping| JPA
    JPA -->|JDBC Connection| DB
```

---

## Lab 2: Enterprise EE Containerized Monolith Architecture

```mermaid
flowchart TD
    subgraph Clients["Client & API Documentation Tier"]
        UserApp["Web / Mobile App Client"]
        Swagger["Swagger UI / OpenAPI\n(/openapi or /swagger-ui)"]
    end

    subgraph DockerEnv["Docker Compose Network Boundary (digibank-net)"]
        subgraph WildFly["WildFly 33 Application Server Container (Port 8080)"]
            subgraph RestAPI["JAX-RS REST Controller Endpoints"]
                CustRes["CustomerResource\n(/api/v1/customers)"]
                AccRes["AccountResource\n(/api/v1/accounts)"]
                TxRes["TransactionResource\n(/api/v1/transactions)"]
            end

            subgraph EJBLayer["Enterprise Business Logic (@Stateless EJBs)"]
                CustEJB["Customer EJB"]
                AccEJB["Account EJB"]
                TxEJB["Transaction EJB"]
                CompEJB["Compliance Rule EJB"]
            end

            JPAPool["Jakarta Persistence 3.1 & Managed DS Pool\n(java:jboss/datasources/PostgreSQLDS)"]
        end

        subgraph DBContainer["PostgreSQL Container (Port 5432)"]
            PostgresDB[("PostgreSQL 17 Database\n(Database: digibank_db)")]
        end
    end

    UserApp -->|HTTP / REST JSON| RestAPI
    Swagger -->|OpenAPI Specs| RestAPI

    RestAPI -->|CDI @Inject| EJBLayer
    CustEJB -->|Risk Validation| CompEJB
    TxEJB -->|Rule Check| CompEJB

    EJBLayer --> JPAPool
    JPAPool -->|JDBC TCP Port 5432| PostgresDB
```

---

## Lab 3: Cloud-Native Microservices Architecture

```mermaid
flowchart TD
    subgraph Clients["Client Ingress Tier"]
        MobileWeb["Web Portal / Mobile Client"]
    end

    subgraph APIInfra["API Infrastructure & Routing"]
        Gateway["Spring Cloud API Gateway\n(Port 8080 / Central Ingress)"]
        Eureka["Eureka Service Registry\n(Port 8761 / Service Discovery)"]
        SwaggerAgg["Aggregated Swagger UI\n(Unified OpenAPI Portal)"]
    end

    subgraph Microservices["Decoupled Microservices Ecosystem (Database-per-Service)"]
        subgraph CustomerMS["Customer Microservice (Port 8081)"]
            CustSvc["Customer REST & Service"]
            CustDB[(Customer DB)]
            CustSvc --> CustDB
        end

        subgraph AccountMS["Account Microservice (Port 8082)"]
            AccSvc["Account REST & Service"]
            AccDB[(Account DB)]
            AccSvc --> AccDB
        end

        subgraph TransactionMS["Transaction Microservice (Port 8083)"]
            TxSvc["Transaction REST & Service"]
            TxDB[(Transaction DB)]
            TxSvc --> TxDB
        end

        subgraph ComplianceMS["Compliance Microservice (Port 8084)"]
            CompSvc["Compliance REST & Rules Engine"]
            CompDB[(Compliance DB)]
            CompSvc --> CompDB
        end
    end

    subgraph Eventing["Inter-Service Communication"]
        EventBus["RabbitMQ / Kafka Event Bus\n(Async Audit & Compliance Streams)"]
    end

    MobileWeb -->|HTTPS / REST| Gateway
    Gateway <-->|Register & Discover| Eureka
    
    Gateway -->|Route /api/v1/customers| CustSvc
    Gateway -->|Route /api/v1/accounts| AccSvc
    Gateway -->|Route /api/v1/transactions| TxSvc
    Gateway -->|Route /api/v1/compliance| CompSvc

    SwaggerAgg -.-> Gateway

    TxSvc -->|Sync OpenFeign REST Call| AccSvc
    TxSvc -->|Async Compliance Event| EventBus
    EventBus -->|Consume Event| CompSvc
```
