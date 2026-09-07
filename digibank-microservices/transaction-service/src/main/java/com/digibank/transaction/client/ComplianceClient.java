package com.digibank.transaction.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.math.BigDecimal;
import java.util.Map;

@FeignClient(name = "compliance-service", path = "/compliance")
public interface ComplianceClient {

    @GetMapping("/validate/{amount}")
    Map<String, Boolean> validateAmount(@PathVariable BigDecimal amount);
}
