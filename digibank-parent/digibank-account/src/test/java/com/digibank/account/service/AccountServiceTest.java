package com.digibank.account.service;

import com.digibank.account.model.Account;
import com.digibank.account.repository.AccountRepository;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;

import java.util.List;

public class AccountServiceTest {

    @Mock
    private AccountRepository repository;

    @InjectMocks
    private AccountService service;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testCreateAccount() {
        Account acc = new Account("ACC-100", 2500.0);
        service.createAccount(acc);
        Mockito.verify(repository, Mockito.times(1)).save(acc);
    }

    @Test
    void testGetAccounts() {
        Account acc = new Account("ACC-100", 2500.0);
        Mockito.when(repository.findAll()).thenReturn(List.of(acc));

        List<Account> accounts = service.getAccounts();
        Assertions.assertEquals(1, accounts.size());
        Assertions.assertEquals("ACC-100", accounts.get(0).getAccountNumber());
    }
}
