package com.digibank.customer;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Contact;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.info.License;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@OpenAPIDefinition(
        info = @Info(
                title = "Digi Bank Customer Service",
                description = "Manages customer registration and consultation within the Digi Bank microservices architecture. "
                        + "Backed by a dedicated PostgreSQL database and registered with the Eureka discovery server.",
                version = "1.0.0",
                termsOfService = "https://digibank.example.com/terms",
                contact = @Contact(name = "Digi Bank Platform Team", email = "platform@digibank.example.com"),
                license = @License(name = "Apache 2.0", url = "https://www.apache.org/licenses/LICENSE-2.0")
        )
)
public class CustomerServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(CustomerServiceApplication.class, args);
    }
}
