package com.digibank.account.service;

import com.digibank.account.model.Account;
import jakarta.ejb.Stateless;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Stateless
public class AccountService {

    private static final List<Account> ACCOUNTS = new ArrayList<>();

    public void createAccount(Account account) {
        ACCOUNTS.add(account);
    }

    public List<Account> getAccounts() {
        return Collections.unmodifiableList(ACCOUNTS);
    }
}
