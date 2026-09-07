package com.digibank.compliance.service;

import org.junit.jupiter.api.Test;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;

class ComplianceServiceTest {

    private final ComplianceService service = new ComplianceService();

    @Test
    void acceptsAmountAtOrBelowLimit() {
        assertThat(service.validateTransactionAmount(new BigDecimal("5000.00"))).isTrue();
        assertThat(service.validateTransactionAmount(new BigDecimal("10000.00"))).isTrue();
    }

    @Test
    void rejectsAmountAboveLimitOrMissing() {
        assertThat(service.validateTransactionAmount(new BigDecimal("25000.00"))).isFalse();
        assertThat(service.validateTransactionAmount(null)).isFalse();
    }
}
