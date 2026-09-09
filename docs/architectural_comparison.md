# 🏦 DigiBank Architectural Blueprint & Lab Comparison Guide (Labs 1 – 4)

> **Course**: UCC 122-1 · Cloud Architecture  
> **Institution**: Professional Bachelor's Degree in Cloud Computing — University of the Mountains  
> **Supervisor**: Engineer Willy Damtchou · Academic Year 2025/2026

---

## 📌 Executive Summary

The **DigiBank** codebase serves as a comprehensive practical demonstration of software architecture evolution. Over the course of four lab modules, the application transitions from an abstract domain model to a Jakarta EE enterprise monolith, to a modern Spring Boot monolith, and finally to a distributed Spring Cloud microservices mesh.

```
[ Lab 1 ] ─────────────────▶ [ Lab 2 ] ─────────────────▶ [ Lab 3 ] ─────────────────▶ [ Lab 4 ]
Domain Analysis &            Jakarta EE 10                Spring Boot 3.5              Spring Cloud Microservices
Cloud Readiness              Modular Monolith             Modular Monolith             Distributed Architecture
(DDD & 12-Factor)            (Single WAR / WildFly)       (Single WAR / WildFly)       (Docker / Eureka / Gateway)
```

---

## 🏛️ 1. In-Depth Breakdown by Architectural Stage

### 📋 Lab 1: Architecture Foundation & Domain Analysis
* **Primary Objective**: Analyze business requirements, define architectural boundaries using Domain-Driven Design (DDD), and evaluate cloud readiness.
* **Core Concepts**:
  * **Bounded Contexts**: Divided the banking domain into 5 autonomous functional domains:
    1. **Customer**: Customer profile, identification, and metadata management.
    2. **Account**: Financial account lifecycles, balances, and multi-currency tracking.
    3. **Transaction**: Deposits, withdrawals, and inter-account funds transfers.
    4. **Compliance**: Regulatory rule enforcement, high-value transaction monitoring, and risk validation.
    5. **Notification**: Asynchronous and event-driven customer alerts (email/SMS mock).
  * **12-Factor App Evaluation**: Assessed codebase compliance against 12-Factor App methodology (Configuration via environment, Stateless execution, Port binding, Log streaming, Dev/Prod parity).
  * **Architectural Trade-Off Analysis**: Established why starting with a monolith with clear internal module boundaries prevents premature distributed system complexity.

---

### 🏛️ Lab 2: Modular Monolith (Jakarta EE 10 + WildFly 33)
* **Primary Objective**: Implement core business logic inside a structured modular monolithic architecture using Java enterprise standards.
* **Technology Stack**:
  * **Enterprise Specification**: **Jakarta EE 10**
  * **REST Layer**: `JAX-RS` (`@Path`, `@GET`, `@POST`, `@Produces`, `@Consumes`)
  * **Business Logic Layer**: `EJB 3.2` (`@Stateless` enterprise beans with `@Local` interfaces)
  * **Dependency Injection**: `CDI 4.0` (`@Inject`, `@Named`, `@ApplicationScoped`)
  * **Persistence Layer**: `JPA 3.1` / `Hibernate 6` (`@Entity`, `@Table`, `@Id`, `EntityManager`)
  * **Application Server**: **WildFly 33.0.2.Final**
  * **Database**: **Single Shared PostgreSQL Database** (`digibank_db`) on host port `5434`
* **Packaging & Execution Model**:
  * Maven Multi-Module Reactor (`digibank-parent/pom.xml`).
  * Sub-modules (`digibank-shared`, `digibank-customer`, `digibank-account`, `digibank-transaction`, `digibank-compliance`, `digibank-index`) compile into individual `.jar` archives.
  * The assembly module (`digibank-app`) packages all module JARs into `WEB-INF/lib` of a single `digibank-app.war` artifact deployed to WildFly.
* **Code Example (Jakarta EE)**:
  ```java
  // JAX-RS REST Controller
  @Path("/customers")
  @Produces(MediaType.APPLICATION_JSON)
  @Consumes(MediaType.APPLICATION_JSON)
  public class CustomerResource {
      @Inject
      private CustomerService customerService;

      @POST
      public Response createCustomer(CustomerDTO dto) {
          Customer created = customerService.createCustomer(dto);
          return Response.status(Response.Status.CREATED).entity(created).build();
      }
  }
  ```

---

### 🍃 Lab 3: Modular Monolith Migration (Spring Boot 3.5 + WildFly 33)
* **Primary Objective**: Modernize the framework foundation to Spring Boot while preserving the single-artifact WAR deployment topology on WildFly.
* **Technology Stack**:
  * **Framework**: **Spring Boot 3.5** (`Spring Web`, `Spring Data JPA`, `Spring Core`)
  * **REST Layer**: Spring Web (`@RestController`, `@RequestMapping`, `@GetMapping`, `@PostMapping`)
  * **Business Logic Layer**: Spring Core (`@Service`, `@Transactional`, `@Autowired`)
  * **Persistence Layer**: Spring Data JPA (`JpaRepository<T, ID>`, `@Entity`)
  * **Application Server**: WildFly 33 (via `SpringBootServletInitializer` producing a WAR package)
  * **Database**: **Single Shared PostgreSQL Database** (`digibank_db`) on host port `5435`
* **Packaging & Execution Model**:
  * Maven Multi-Module Reactor (`digibank-parent-spring/pom.xml`).
  * Extends `SpringBootServletInitializer` in `DigiBankSpringApplication.java` to support traditional web server deployment.
  * Bundled into a single `digibank-app.war` and deployed on WildFly port `9091`.
* **Code Example (Spring Boot)**:
  ```java
  // Spring RestController
  @RestController
  @RequestMapping("/api/customers")
  public class CustomerController {
      @Autowired
      private CustomerService customerService;

      @PostMapping
      public ResponseEntity<CustomerResponse> createCustomer(@Valid @RequestBody CreateCustomerRequest request) {
          CustomerResponse created = customerService.createCustomer(request);
          return ResponseEntity.status(HttpStatus.CREATED).body(created);
      }
  }
  ```

---

### 🌐 Lab 4: Distributed Microservices Architecture (Spring Cloud + Docker)
* **Primary Objective**: Fully decompose the system into autonomous, loosely coupled, independently deployable microservices orchestrated via Spring Cloud and Docker.
* **Technology Stack**:
  * **Framework**: Spring Boot 3.4 + **Spring Cloud 2024.0.1**
  * **Containerization & Orchestration**: Docker, Docker Compose
  * **Service Discovery**: **Netflix Eureka Discovery Server** (`discovery-server`, Port `8761`)
  * **Configuration Management**: **Spring Cloud Config Server** (`config-server`, Port `8888`)
  * **API Gateway**: **Spring Cloud API Gateway** (`api-gateway`, Port `8080`)
* **Microservices Breakdown**:
  1. `customer-service` (Port `8081`): Customer lifecycle & persistence.
  2. `account-service` (Port `8082`): Account balances & account operations.
  3. `transaction-service` (Port `8083`): Funds transfer Saga orchestration.
  4. `compliance-service` (Port `8084`): Real-time transaction validation.
  5. `notification-service` (Port `8085`): Alert notifications & audit trails.
* **Database Architecture**: **Database-per-Service Pattern**.
  * 5 isolated PostgreSQL containers:
    * `customer-db` (Port `5433`, DB `digibank_customer_db`)
    * `account-db` (Port `5438`, DB `digibank_account_db`)
    * `transaction-db` (Port `5435`, DB `digibank_transaction_db`)
    * `compliance-db` (Port `5436`, DB `digibank_compliance_db`)
    * `notification-db` (Port `5437`, DB `digibank_notification_db`)
* **Communication & Routing Flow**:
  * External Client $\rightarrow$ API Gateway (`http://localhost:8080/api/...`).
  * API Gateway strips prefix (`/api/customers/**` $\rightarrow$ `/customers/**`) and queries Eureka for active instances of `customer-service`.
  * Inter-service synchronous calls use OpenFeign / RestTemplate resolved dynamically via Eureka (e.g., `transaction-service` invoking `compliance-service`).

---

## 📊 2. Comprehensive Architectural Comparison Matrix

| Architectural Axis | Lab 2 (Jakarta EE Monolith) | Lab 3 (Spring Boot Monolith) | Lab 4 (Spring Cloud Microservices) |
|---|---|---|---|
| **System Topology** | Single Process (Monolith) | Single Process (Monolith) | Distributed Service Mesh (8 Microservices) |
| **Primary Framework** | Jakarta EE 10 | Spring Boot 3.5 | Spring Boot 3.4 + Spring Cloud 2024 |
| **Deployment Unit** | 1 WAR File (`digibank-app.war`) | 1 WAR File (`digibank-app.war`) | 8 Independent Docker Container Images |
| **Runtime Container** | WildFly 33 Application Server | WildFly 33 Application Server | Embedded Tomcat / Netty inside Docker containers |
| **Database Model** | Single Shared Database (`digibank_db`) | Single Shared Database (`digibank_db`) | **Database-per-Service** (5 Isolated PostgreSQL DBs) |
| **Inter-Module Communication** | Direct in-memory Java method calls | Direct in-memory Java method calls | Network calls over HTTP REST / OpenFeign |
| **Service Discovery** | Not required (In-process memory) | Not required (In-process memory) | **Netflix Eureka Server** (`http://localhost:8761`) |
| **Centralized Config** | JBoss / WildFly `standalone.xml` & JNDI | `application.yml` embedded in WAR | **Spring Cloud Config Server** (`http://localhost:8888`) |
| **Edge Routing / Gateway** | Direct access via WildFly HTTP port `9090` | Direct access via WildFly HTTP port `9091` | **Spring Cloud API Gateway** (`http://localhost:8080`) |
| **Fault Isolation** | Low (Unhandled exception or memory leak affects entire WAR) | Low (Unhandled exception or memory leak affects entire WAR) | High (Failure in `notification-service` does not impact `customer-service`) |
| **Scalability** | Scale-up entire WAR (Horizontal replication of whole monolith) | Scale-up entire WAR (Horizontal replication of whole monolith) | Scale-out individual services independently (e.g., 5 instances of `transaction-service`) |

---

## ⚙️ 3. Execution & Automation Control Center

The repository includes dedicated, automated interactive control scripts for each architecture:

| Architecture Stage | Automation Script | Execution Command | Core Tasks Performed |
|---|---|---|---|
| **Lab 2: Jakarta EE Monolith** | `setup.sh` | `./setup.sh` | Builds WAR, starts PostgreSQL (`5434`) & WildFly (`9090`), deploys WAR, runs endpoint curl suite. |
| **Lab 3: Spring Boot Monolith** | `setup-spring.sh` | `./setup-spring.sh` | Builds Spring Boot WAR, starts PostgreSQL (`5435`) & WildFly (`9091`), runs BDD tests & endpoint diagnostics. |
| **Lab 4: Microservices** | `setup-microservices.sh` | `./setup-microservices.sh` | Verifies `.env`, runs Maven reactor package, launches 13 Docker containers (5 DBs + Eureka + Config + Gateway + 5 Services), verifies Gateway API. |

---

## 🎯 4. Technical Defense & Exam Preparation Q&A

### Q1: What is the fundamental difference between a Modular Monolith and a Microservices Architecture?
> **Answer**: 
> A **Modular Monolith** enforces strict domain separation at the *code structure level* (packages/modules), but all modules are compiled into a *single deployment unit* that shares a single database and executes within a single Java Virtual Machine (JVM).
> A **Microservices Architecture** enforces domain separation at the *process level*. Each microservice runs in its own JVM/container, manages its own private database (Database-per-Service), and communicates across the network via REST or messaging.

### Q2: Why start with a Modular Monolith before transitioning to Microservices?
> **Answer**: 
> Starting with a Modular Monolith allows software teams to validate business logic, define domain boundaries, and establish stable API contracts without incurring the operational overhead of distributed systems (such as network latency, circuit breaking, distributed tracing, and data consistency management). Refactoring a clean modular monolith into microservices is significantly easier than refactoring a chaotic "spaghetti" monolith.

### Q3: How does Service Discovery work in Lab 4?
> **Answer**: 
> In Lab 4, we use **Netflix Eureka Server**. When each microservice boots up, it registers its service name (e.g. `customer-service`) and dynamic network location (IP/port) with Eureka on port `8761`. When the **API Gateway** or another microservice needs to invoke `customer-service`, it queries Eureka to retrieve active service instances and load-balances requests dynamically without hardcoded URLs.

### Q4: Why is the Database-per-Service pattern critical in Microservices?
> **Answer**: 
> Sharing a single database across microservices creates tight coupling at the database schema level. If one service changes a table structure, it can break other services. The Database-per-Service pattern guarantees that microservices are fully autonomous, allowing independent database schema migrations, technology choices, and isolated database scaling.

### Q5: How is configuration managed centrally in Lab 4?
> **Answer**: 
> Microservices fetch their configuration at startup from the **Spring Cloud Config Server** (port `8888`), which reads configuration YAML files from `digibank-microservices/config-repo`. This allows configuration changes across all services to be managed centrally without rebuilding service container images.
