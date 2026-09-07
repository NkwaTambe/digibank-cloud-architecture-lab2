package com.digibank.app.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI digiBankOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Digi Bank - REST API")
                        .description("Interactive API playground for the Digi Bank Modular Monolith (Spring Boot 3.5).")
                        .version("1.0.0"));
    }
}
