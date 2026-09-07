package com.digibank.compliance.service;

import org.springframework.stereotype.Service;

import java.math.BigDecimal;

@Service
public class ComplianceService {

    private static final BigDecimal LIMIT = new BigDecimal("10000.00");

    public boolean validateTransactionAmount(BigDecimal amount) {
        return amount != null && amount.compareTo(LIMIT) <= 0;
    }
}
