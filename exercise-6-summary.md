# Exercise 6: Common Jakarta EE Setup Summary

This PR/update implements **Exercise 6 (Common Jakarta EE Setup)** of Lab 2. It sets up JAX-RS activation and the JPA database persistence unit configuration for the modular monolithic application.

---

## 📁 Implemented Files

### 1. JAX-RS Activation Class
- **File**: [`DigiBankApplication.java`](file:///home/bryan/School-Work/cloud-A/digibank-cloud-architecture-lab2/digibank-parent/digibank-app/src/main/java/com/digibank/app/DigiBankApplication.java)
- **Path**: `com.digibank.app.DigiBankApplication`
- **Details**: Activates JAX-RS (REST services) and exposes all endpoints under the `/api` root path (e.g. `http://localhost:8080/digibank-app/api/...`).

### 2. JPA Datasource configuration
- **File**: [`persistence.xml`](file:///home/bryan/School-Work/cloud-A/digibank-cloud-architecture-lab2/digibank-parent/digibank-app/src/main/resources/META-INF/persistence.xml)
- **Details**: Defines the persistence unit `digibankPU` configured to connect to the JTA data source `java:/jdbc/DigiBankDS` in WildFly. It uses the `update` database action strategy to auto-generate the schema columns upon startup.

---

## 🛠️ Verification and Build Status

Run the following command from the root of the project to clean, compile, and install the modules:

```bash
mvn clean install
```

**Status**: Build compiles and packages successfully into target files.
