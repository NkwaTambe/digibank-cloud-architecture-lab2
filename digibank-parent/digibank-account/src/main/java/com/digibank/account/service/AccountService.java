package com.digibank.account.service;

import com.digibank.account.model.Account;
import com.digibank.account.repository.AccountRepository;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import java.util.List;

@Stateless
public class AccountService {

    @Inject
    private AccountRepository repository;

    public void createAccount(Account account) {
        repository.save(account);
    }

    public Account getAccount(Long id) {
        return repository.findById(id);
    }

    public List<Account> getAccounts() {
        return repository.findAll();
    }
}
