package com.digibank.transaction.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "transactions")
@Schema(name = "Transaction", description = "A single monetary movement recorded for an account.")
public class Transaction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Schema(description = "Unique transaction identifier.", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    private Long id;

    @Column(nullable = false)
    @Schema(description = "Account the transaction belongs to.", example = "1", requiredMode = Schema.RequiredMode.REQUIRED)
    private Long accountId;

    @Column(nullable = false, precision = 19, scale = 2)
    @Schema(description = "Transaction amount.", example = "150.00", requiredMode = Schema.RequiredMode.REQUIRED)
    private BigDecimal amount;

    @Column(nullable = false)
    @Schema(description = "Transaction type (e.g. DEBIT, CREDIT, TRANSFER).", example = "TRANSFER", requiredMode = Schema.RequiredMode.REQUIRED)
    private String type;

    @Column(nullable = false)
    @Schema(description = "Timestamp of when the transaction was recorded.", accessMode = Schema.AccessMode.READ_ONLY)
    private Instant createdAt = Instant.now();

    public Transaction() {
    }

    public Transaction(Long accountId, BigDecimal amount, String type) {
        this.accountId = accountId;
        this.amount = amount;
        this.type = type;
    }

    public Long getId() {
        return id;
    }

    public Long getAccountId() {
        return accountId;
    }

    public void setAccountId(Long accountId) {
        this.accountId = accountId;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }
}
