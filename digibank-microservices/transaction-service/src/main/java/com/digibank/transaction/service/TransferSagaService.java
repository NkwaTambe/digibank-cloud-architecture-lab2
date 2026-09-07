package com.digibank.transaction.service;

import com.digibank.transaction.client.AccountClient;
import com.digibank.transaction.client.ComplianceClient;
import com.digibank.transaction.client.NotificationClient;
import com.digibank.transaction.command.CreateTransactionCommand;
import com.digibank.transaction.command.TransactionCommandHandler;
import com.digibank.transaction.model.Transaction;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Map;

@Service
public class TransferSagaService {

    private final ComplianceClient complianceClient;
    private final AccountClient accountClient;
    private final NotificationClient notificationClient;
    private final TransactionCommandHandler commandHandler;

    public TransferSagaService(
            ComplianceClient complianceClient,
            AccountClient accountClient,
            NotificationClient notificationClient,
            TransactionCommandHandler commandHandler) {
        this.complianceClient = complianceClient;
        this.accountClient = accountClient;
        this.notificationClient = notificationClient;
        this.commandHandler = commandHandler;
    }

    public Transaction executeTransfer(Long fromAccountId, Long toAccountId, BigDecimal amount) {
        if (!isCompliant(amount)) {
            throw new IllegalStateException("Compliance rejected transfer amount: " + amount);
        }

        debit(fromAccountId, amount);
        try {
            credit(toAccountId, amount);
        } catch (RuntimeException ex) {
            credit(fromAccountId, amount);
            throw new IllegalStateException("Transfer failed and debit was compensated", ex);
        }

        Transaction transaction = commandHandler.handle(new CreateTransactionCommand(fromAccountId, amount, "TRANSFER"));
        sendTransferNotification(amount);
        return transaction;
    }

    @CircuitBreaker(name = "compliance-service", fallbackMethod = "complianceFallback")
    boolean isCompliant(BigDecimal amount) {
        return Boolean.TRUE.equals(complianceClient.validateAmount(amount).get("valid"));
    }

    @CircuitBreaker(name = "account-service", fallbackMethod = "accountFallback")
    void debit(Long accountId, BigDecimal amount) {
        accountClient.debit(accountId, Map.of("amount", amount));
    }

    @CircuitBreaker(name = "account-service", fallbackMethod = "accountFallback")
    void credit(Long accountId, BigDecimal amount) {
        accountClient.credit(accountId, Map.of("amount", amount));
    }

    @CircuitBreaker(name = "notification-service", fallbackMethod = "notificationFallback")
    void sendTransferNotification(BigDecimal amount) {
        notificationClient.sendNotification(Map.of("type", "TRANSFER", "message", "Transfer of " + amount + " completed"));
    }

    boolean complianceFallback(BigDecimal amount, Throwable throwable) {
        return false;
    }

    void accountFallback(Long accountId, BigDecimal amount, Throwable throwable) {
        throw new IllegalStateException("Account service unavailable", throwable);
    }

    void notificationFallback(BigDecimal amount, Throwable throwable) {
        // A failed notification must not roll back an already completed transfer.
    }
}
