# Digi Bank — Development Notes

## Order of Development

1. **Environment Setup**: Installed JDK 17, Maven 3.9+, PostgreSQL 18, WildFly 33.0.2.Final,
   and configured VS Code with the required Java/Maven/Cucumber extensions.

2. **Database Creation**: Executed the `db/init.sql` script as the PostgreSQL superuser to
   create the `digibank_db` database and `digibank_user` role with appropriate grants.

3. **Maven Parent Structure**: Created `digibank-parent/pom.xml` as the reactor POM,
   declaring all 7 child modules and centralizing dependency/plugin management
   (Jakarta EE 10, JUnit 5.10.2, Cucumber 7.15.0).

4. **Shared Module (`digibank-shared`)**: Built the foundation — `BaseEntity` as
   a `@MappedSuperclass` with auto-generated ID, and `ApiResponse` as a reusable DTO.

5. **Customer Module (`digibank-customer`)**: Full JPA stack — `Customer` entity with
   `@Entity`/`@Table`, `CustomerRepository` with `EntityManager`, `CustomerService`
   with business logic, `CustomerResource` with JAX-RS REST endpoints.

6. **Account Module (`digibank-account`)**: Entity + simplified in-memory `ArrayList`
   service + REST resource (as specified for this lab phase).

7. **Transaction Module (`digibank-transaction`)**: Same in-memory pattern as Account,
   with Transaction entity, service, and REST resource.

8. **Compliance Module (`digibank-compliance`)**: Business rule validation service
   (`amount <= 10000`) + REST resource for amount validation.

9. **Index Module (`digibank-index`)**: JSP landing page with a servlet forwarding
   mechanism, styled with CSS gradients and module/endpoint information.

10. **App Assembly (`digibank-app`)**: JAX-RS activation via `@ApplicationPath("/api")`,
    `persistence.xml` with JTA datasource, WAR overlay of the index module.

11. **WildFly Configuration**: Configured the PostgreSQL JDBC driver module, datasource
    in `standalone.xml`, and the `wildfly-maven-plugin` for automated deployment.

12. **Testing**: Implemented JUnit 5 unit tests for `ComplianceService` and Cucumber
    BDD scenarios for transaction amount validation.

13. **Deployment & Verification**: Built with `mvn clean install`, deployed with
    `wildfly:deploy`, and verified all REST endpoints using curl.

## Main Difficulties Encountered

- **WildFly Datasource Configuration**: Ensuring the JNDI name `java:/jdbc/DigiBankDS`
  in `standalone.xml` matched exactly with the `persistence.xml` reference required
  careful attention to naming conventions.

- **CDI Injection Across Modules**: Understanding how CDI discovers beans in a
  multi-module WAR overlay setup. Adding explicit `beans.xml` with
  `bean-discovery-mode="all"` ensured reliable injection.

- **Cucumber + JUnit Platform Integration**: Setting up the `@Suite` runner with
  `@IncludeEngines("cucumber")` required the correct combination of
  `cucumber-junit-platform-engine` and `junit-platform-suite-api` dependencies.

- **Maven Module Ordering**: The reactor build order matters — `digibank-shared` must
  build before modules that depend on it. Maven handles this via dependency analysis,
  but understanding the dependency graph was important.

- **PostgreSQL Collation Versioning**: On some systems, a glibc upgrade after PostgreSQL
  cluster initialization causes collation version mismatch warnings. The `init.sql`
  script addresses this with `ALTER DATABASE ... REFRESH COLLATION VERSION`.
