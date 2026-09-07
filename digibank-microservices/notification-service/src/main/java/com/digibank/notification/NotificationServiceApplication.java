package com.digibank.notification;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Contact;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.info.License;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@OpenAPIDefinition(
        info = @Info(
                title = "Digi Bank Notification Service",
                description = "Produces business notifications after sensitive operations such as transfers. "
                        + "Invoked by the Transaction Service to confirm money movement.",
                version = "1.0.0",
                termsOfService = "https://digibank.example.com/terms",
                contact = @Contact(name = "Digi Bank Platform Team", email = "platform@digibank.example.com"),
                license = @License(name = "Apache 2.0", url = "https://www.apache.org/licenses/LICENSE-2.0")
        )
)
public class NotificationServiceApplication {

    public static void main(String[] args) {
        SpringApplication.run(NotificationServiceApplication.class, args);
    }
}
