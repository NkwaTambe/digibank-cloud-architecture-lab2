package com.digibank.account.service;

import com.digibank.account.model.Account;
import com.digibank.account.repository.AccountRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class AccountService {

    private final AccountRepository repository;

    public AccountService(AccountRepository repository) {
        this.repository = repository;
    }

    public Account createAccount(Account account) {
        return repository.save(account);
    }

    public Optional<Account> getAccount(Long id) {
        return repository.findById(id);
    }

    public List<Account> getAccounts() {
        return repository.findAll();
    }
}
