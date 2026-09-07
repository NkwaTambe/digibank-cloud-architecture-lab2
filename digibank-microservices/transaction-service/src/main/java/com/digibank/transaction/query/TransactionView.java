package com.digibank.transaction.query;

import java.math.BigDecimal;

public record TransactionView(Long id, Long accountId, BigDecimal amount, String type) {
}
