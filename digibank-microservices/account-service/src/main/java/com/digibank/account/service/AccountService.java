package com.digibank.account.service;

import com.digibank.account.model.Account;
import com.digibank.account.repository.AccountRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
public class AccountService {

    private final AccountRepository repository;

    public AccountService(AccountRepository repository) {
        this.repository = repository;
    }

    public Account createAccount(Account account) {
        return repository.save(account);
    }

    public Account getAccount(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Account not found: " + id));
    }

    public List<Account> getAccounts() {
        return repository.findAll();
    }

    @Transactional
    public Account debit(Long id, BigDecimal amount) {
        Account account = getAccount(id);
        if (account.getBalance().compareTo(amount) < 0) {
            throw new IllegalStateException("Insufficient balance for account: " + id);
        }
        account.setBalance(account.getBalance().subtract(amount));
        return repository.save(account);
    }

    @Transactional
    public Account credit(Long id, BigDecimal amount) {
        Account account = getAccount(id);
        account.setBalance(account.getBalance().add(amount));
        return repository.save(account);
    }
}
