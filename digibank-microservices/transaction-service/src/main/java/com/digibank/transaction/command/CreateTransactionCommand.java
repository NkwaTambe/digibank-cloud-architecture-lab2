package com.digibank.transaction.command;

import java.math.BigDecimal;

public record CreateTransactionCommand(Long accountId, BigDecimal amount, String type) {
}
