# Digi Bank (Spring Boot) — Development Notes

> **UCC 122-1 · Cloud Architecture · Lab 3**
> A short note explaining the order of development followed and the main difficulties encountered.

---

## 1. Order of development

The implementation followed the workshop's progressive structure, mirroring the Lab 2 (Jakarta EE) reference project:

1. **Environment preparation** — verified JDK 17, Maven, Git, PostgreSQL and Docker.
2. **Database setup** — created `digibank_db` and `digibank_user` via `db/init-spring.sql`.
3. **Multi-module Maven scaffold** — created `digibank-parent-spring` parent POM (BOM import of `spring-boot-dependencies` 3.5.15) and the 7 module directories.
4. **`digibank-shared`** — `BaseEntity` (`@MappedSuperclass`) and `ApiResponse` DTO.
5. **`digibank-customer`** — `Customer` entity, `CustomerRepository` (Spring Data JPA), `CustomerService`, `CustomerController`.
6. **`digibank-account`** — `Account` entity, repository, service, controller.
7. **`digibank-transaction`** — `Transaction` entity, repository, service, controller.
8. **`digibank-compliance`** — `ComplianceService` + `ComplianceController`.
9. **`digibank-index`** — `IndexController` (Thymeleaf) + `templates/index.html`.
10. **`digibank-app`** — `DigiBankApplication extends SpringBootServletInitializer`, WAR packaging, `application.properties` with JNDI datasource.
11. **WildFly configuration** — PostgreSQL driver module + `java:/jdbc/DigiBankDS` datasource (via `Dockerfile.wildfly`).
12. **Compile, package, deploy** — `mvn clean install`, WAR generation, deployment on WildFly.
13. **Functional checks** — verified all REST endpoints with `curl`.
14. **JUnit tests** — `ComplianceServiceTest`.
15. **Cucumber BDD** — `compliance.feature`, `ComplianceSteps`, `RunCucumberTest`.
16. **One-script startup** — `setup-spring.sh` automating build + Docker deploy + endpoint tests.

---

## 2. Main difficulties encountered

### 2.1 Multi-module component scanning
`@SpringBootApplication` only scans the package of the main class (`com.digibank.app`) by default. Because the controllers, services, repositories and entities live in sibling modules (`com.digibank.customer`, `com.digibank.account`, ...), the application would not start them. This was solved by explicitly declaring on the main class:

```java
@ComponentScan(basePackages = "com.digibank")
@EntityScan(basePackages = "com.digibank")
@EnableJpaRepositories(basePackages = "com.digibank")
```

### 2.2 `@PathVariable` name resolution (HTTP 500)
Deployed on WildFly, requests such as `/api/compliance/validate/5000` failed with:
> *Name for argument of type [java.lang.Double] not specified, and parameter name information not available via reflection.*

Because we use a custom parent POM (not `spring-boot-starter-parent`), the `-parameters` compiler flag is not set by default. Fixed by adding `<parameters>true</parameters>` to the `maven-compiler-plugin` configuration in the parent POM.

### 2.3 Column naming mismatch with the Lab 2 `init.sql`
The Lab 2 `db/init.sql` pre-creates tables with camelCase columns (`firstName`, `lastName`, `accountNumber`), but Spring Boot's default Hibernate naming strategy maps fields to snake_case (`first_name`, `last_name`, `account_number`). Inserts then failed with NOT NULL violations. Fixed by creating a dedicated `db/init-spring.sql` that only creates the database and user, letting Hibernate (`ddl-auto=update`) create the tables with the correct physical names.

### 2.4 WAR deployment on an external container
To deploy on WildFly rather than the embedded Tomcat, the `spring-boot-starter-tomcat` dependency is excluded, `jakarta.servlet-api` and `slf4j-api` are marked `provided`, and the main class extends `SpringBootServletInitializer` overriding `configure(...)`.

### 2.5 Idempotent endpoint tests
The endpoint test script initially used fixed unique values (email / account number). Re-running the script against an already-populated database caused duplicate-key errors. Fixed by generating a unique suffix per run.

---

## 3. Result

A first stable, executable version of Digi Bank in Spring Boot: modular monolith, PostgreSQL persistence, REST endpoints, WAR package deployable on WildFly, JUnit tests and Cucumber BDD scenarios — all startable with a single command:

```bash
./setup-spring.sh docker
```
