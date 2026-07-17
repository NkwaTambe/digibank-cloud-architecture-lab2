package com.digibank.compliance.service;

import jakarta.ejb.Stateless;

@Stateless
public class ComplianceService {

    public boolean validateTransactionAmount(Double amount) {
        return amount != null && amount <= 10000;
    }
}
