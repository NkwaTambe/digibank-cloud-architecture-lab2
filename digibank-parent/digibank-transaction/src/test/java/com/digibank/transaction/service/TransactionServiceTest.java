package com.digibank.transaction.service;

import com.digibank.transaction.model.Transaction;
import com.digibank.transaction.repository.TransactionRepository;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;

import java.util.List;

public class TransactionServiceTest {

    @Mock
    private TransactionRepository repository;

    @InjectMocks
    private TransactionService service;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testAddTransaction() {
        Transaction tx = new Transaction("DEPOSIT", 1000.0);
        service.addTransaction(tx);
        Mockito.verify(repository, Mockito.times(1)).save(tx);
    }

    @Test
    void testGetTransactions() {
        Transaction tx = new Transaction("DEPOSIT", 1000.0);
        Mockito.when(repository.findAll()).thenReturn(List.of(tx));

        List<Transaction> transactions = service.getTransactions();
        Assertions.assertEquals(1, transactions.size());
        Assertions.assertEquals("DEPOSIT", transactions.get(0).getType());
    }
}
