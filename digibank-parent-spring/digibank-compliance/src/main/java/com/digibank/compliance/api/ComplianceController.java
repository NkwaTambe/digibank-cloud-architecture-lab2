package com.digibank.compliance.api;

import com.digibank.compliance.service.ComplianceService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/compliance")
public class ComplianceController {

    private final ComplianceService service;

    public ComplianceController(ComplianceService service) {
        this.service = service;
    }

    @GetMapping("/validate/{amount}")
    public ResponseEntity<Map<String, Boolean>> validate(@PathVariable Double amount) {
        return ResponseEntity.ok(Map.of("valid", service.validateTransactionAmount(amount)));
    }
}
