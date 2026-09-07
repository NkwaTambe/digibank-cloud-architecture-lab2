package com.digibank.compliance.api;

import com.digibank.compliance.service.ComplianceService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequestMapping("/compliance")
public class ComplianceController {

    private final ComplianceService service;

    public ComplianceController(ComplianceService service) {
        this.service = service;
    }

    @GetMapping("/validate/{amount}")
    public Map<String, Boolean> validate(@PathVariable BigDecimal amount) {
        return Map.of("valid", service.validateTransactionAmount(amount));
    }
}
