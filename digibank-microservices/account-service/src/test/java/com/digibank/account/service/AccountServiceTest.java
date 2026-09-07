package com.digibank.account.service;

import com.digibank.account.model.Account;
import com.digibank.account.repository.AccountRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AccountServiceTest {

    @Mock
    private AccountRepository repository;

    @InjectMocks
    private AccountService service;

    @Test
    void creditsAccountBalance() {
        Account account = new Account("ACC-1001", new BigDecimal("1000.00"));
        when(repository.findById(1L)).thenReturn(Optional.of(account));
        when(repository.save(account)).thenReturn(account);

        Account credited = service.credit(1L, new BigDecimal("250.00"));

        assertThat(credited.getBalance()).isEqualByComparingTo("1250.00");
    }

    @Test
    void rejectsDebitWhenBalanceIsInsufficient() {
        Account account = new Account("ACC-1001", new BigDecimal("100.00"));
        when(repository.findById(1L)).thenReturn(Optional.of(account));

        assertThatThrownBy(() -> service.debit(1L, new BigDecimal("250.00")))
                .isInstanceOf(IllegalStateException.class)
                .hasMessageContaining("Insufficient balance");
    }
}
