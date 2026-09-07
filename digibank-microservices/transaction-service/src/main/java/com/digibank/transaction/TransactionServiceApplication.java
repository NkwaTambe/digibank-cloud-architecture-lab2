package com.digibank.transaction;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Contact;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.info.License;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.openfeign.EnableFeignClients;

@SpringBootApplication
@EnableFeignClients
@OpenAPIDefinition(
        info = @Info(
                title = "Digi Bank Transaction Service",
                description = "Orchestrates money movements: transaction creation, cross-service transfers driven by a Saga, "
                        + "and CQRS read/write separation. Uses Feign clients to call Account, Compliance and Notification services "
                        + "with Resilience4j circuit breakers.",
                version = "1.0.0",
                termsOfService = "https://digibank.example.com/terms",
                contact = @Contact(name = "Digi Bank Platform Team", email = "platform@digibank.example.com"),
                license = @License(name = "Apache 2.0", url = "https://www.apache.org/licenses/LICENSE-2.0")
        )
)
public class TransactionServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(TransactionServiceApplication.class, args);
    }
}
