package com.digibank.compliance.service;

import org.springframework.stereotype.Service;

@Service
public class ComplianceService {

    public boolean validateTransactionAmount(Double amount) {
        return amount != null && amount <= 10000;
    }
}
