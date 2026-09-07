package com.digibank.compliance.api;

import com.digibank.compliance.service.ComplianceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequestMapping("/compliance")
@Tag(name = "Compliance", description = "Endpoints for transaction validation and future KYC/AML rules.")
public class ComplianceController {

    private final ComplianceService service;

    public ComplianceController(ComplianceService service) {
        this.service = service;
    }

    @GetMapping("/validate/{amount}")
    @Operation(summary = "Validate transaction amount", description = "Checks whether a monetary amount is allowed by current compliance rules.")
    public Map<String, Boolean> validate(
            @Parameter(description = "Monetary amount to validate.", example = "5000") @PathVariable BigDecimal amount) {
        return Map.of("valid", service.validateTransactionAmount(amount));
    }
}
