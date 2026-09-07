package com.digibank.gateway;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Contact;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.info.License;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@OpenAPIDefinition(
        info = @Info(
                title = "Digi Bank API Gateway",
                description = "Single entry point for the Digi Bank microservices. Routes requests to Customer, Account, "
                        + "Transaction, Compliance and Notification services via Spring Cloud Gateway and service discovery.",
                version = "1.0.0",
                termsOfService = "https://digibank.example.com/terms",
                contact = @Contact(name = "Digi Bank Platform Team", email = "platform@digibank.example.com"),
                license = @License(name = "Apache 2.0", url = "https://www.apache.org/licenses/LICENSE-2.0")
        )
)
public class ApiGatewayApplication {

    public static void main(String[] args) {
        SpringApplication.run(ApiGatewayApplication.class, args);
    }
}
