package com.digibank.transaction.service;

import io.swagger.v3.oas.annotations.media.Schema;

import java.math.BigDecimal;

@Schema(name = "TransferRequest", description = "Payload for executing a transfer between two accounts via the Saga.")
public record TransferRequest(
        @Schema(description = "Identifier of the source account.", example = "1", requiredMode = Schema.RequiredMode.REQUIRED)
        Long fromAccountId,
        @Schema(description = "Identifier of the destination account.", example = "2", requiredMode = Schema.RequiredMode.REQUIRED)
        Long toAccountId,
        @Schema(description = "Amount to transfer.", example = "300.00", requiredMode = Schema.RequiredMode.REQUIRED)
        BigDecimal amount) {
}
