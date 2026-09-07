package com.digibank.transaction.query;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;

@Schema(name = "TransactionView", description = "Read-side projection of a transaction (CQRS query model).")
public record TransactionView(
        @Schema(description = "Unique transaction identifier.", example = "1") Long id,
        @Schema(description = "Account the transaction belongs to.", example = "1") Long accountId,
        @Schema(description = "Transaction amount.", example = "150.00") BigDecimal amount,
        @Schema(description = "Transaction type.", example = "TRANSFER") String type) {
}
