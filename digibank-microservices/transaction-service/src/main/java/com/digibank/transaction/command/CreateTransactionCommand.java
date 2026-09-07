package com.digibank.transaction.command;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;

@Schema(name = "CreateTransactionCommand", description = "Payload describing a transaction to persist on the write path.")
public record CreateTransactionCommand(
        @Schema(description = "Account the transaction belongs to.", example = "1", requiredMode = Schema.RequiredMode.REQUIRED)
        Long accountId,
        @Schema(description = "Transaction amount.", example = "150.00", requiredMode = Schema.RequiredMode.REQUIRED)
        BigDecimal amount,
        @Schema(description = "Transaction type (e.g. DEBIT, CREDIT, TRANSFER).", example = "TRANSFER", requiredMode = Schema.RequiredMode.REQUIRED)
        String type) {
}
