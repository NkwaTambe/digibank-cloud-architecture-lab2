package com.digibank.transaction.service;

import com.digibank.transaction.client.AccountClient;
import com.digibank.transaction.client.ComplianceClient;
import com.digibank.transaction.client.NotificationClient;
import com.digibank.transaction.command.CreateTransactionCommand;
import com.digibank.transaction.command.TransactionCommandHandler;
import com.digibank.transaction.model.Transaction;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TransferSagaServiceTest {

    @Mock
    private ComplianceClient complianceClient;

    @Mock
    private AccountClient accountClient;

    @Mock
    private NotificationClient notificationClient;

    @Mock
    private TransactionCommandHandler commandHandler;

    @InjectMocks
    private TransferSagaService service;

    @Test
    void rejectsTransferWhenComplianceDeclinesAmount() {
        when(complianceClient.validateAmount(new BigDecimal("25000.00"))).thenReturn(Map.of("valid", false));

        assertThatThrownBy(() -> service.executeTransfer(1L, 2L, new BigDecimal("25000.00")))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("Compliance rejected");
    }

    @Test
    void compensatesDebitWhenCreditFails() {
        when(complianceClient.validateAmount(new BigDecimal("100.00"))).thenReturn(Map.of("valid", true));
        doThrow(new IllegalStateException("credit unavailable")).when(accountClient).credit(2L, Map.of("amount", new BigDecimal("100.00")));

        assertThatThrownBy(() -> service.executeTransfer(1L, 2L, new BigDecimal("100.00")))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("Transfer failed");
        verify(accountClient).credit(1L, Map.of("amount", new BigDecimal("100.00")));
    }

    @Test
    void recordsTransactionAndNotificationWhenTransferCompletes() {
        when(complianceClient.validateAmount(new BigDecimal("100.00"))).thenReturn(Map.of("valid", true));
        Transaction transaction = new Transaction(1L, new BigDecimal("100.00"), "TRANSFER");
        when(commandHandler.handle(new CreateTransactionCommand(1L, new BigDecimal("100.00"), "TRANSFER"))).thenReturn(transaction);

        Transaction completed = service.executeTransfer(1L, 2L, new BigDecimal("100.00"));

        assertThat(completed.getType()).isEqualTo("TRANSFER");
        verify(notificationClient).sendNotification(Map.of("type", "TRANSFER", "message", "Transfer of 100.00 completed"));
    }
}
