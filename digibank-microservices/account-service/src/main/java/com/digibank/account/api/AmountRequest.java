package com.digibank.account.api;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;

@Schema(name = "AmountRequest", description = "Payload carrying the monetary amount for debit or credit operations.")
public record AmountRequest(
        @Schema(description = "Amount to apply to the account balance.", example = "250.00", requiredMode = Schema.RequiredMode.REQUIRED)
        BigDecimal amount) {
}
