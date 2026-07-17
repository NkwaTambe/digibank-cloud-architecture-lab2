package com.digibank.account.service;

import com.digibank.account.model.Account;
import jakarta.ejb.Stateless;
import java.util.ArrayList;
import java.util.List;

@Stateless
public class AccountService {

    private static final List<Account> accounts = new ArrayList<>();

    public void createAccount(Account account) {
        accounts.add(account);
    }

    public List<Account> getAccounts() {
        return accounts;
    }
}
