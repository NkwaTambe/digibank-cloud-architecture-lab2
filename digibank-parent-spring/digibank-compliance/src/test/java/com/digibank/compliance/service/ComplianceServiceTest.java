package com.digibank.compliance.service;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

public class ComplianceServiceTest {

    private final ComplianceService service = new ComplianceService();

    @Test
    void shouldAcceptAmountBelowLimit() {
        Assertions.assertTrue(service.validateTransactionAmount(5000.0));
    }

    @Test
    void shouldRejectAmountAboveLimit() {
        Assertions.assertFalse(service.validateTransactionAmount(20000.0));
    }
}
