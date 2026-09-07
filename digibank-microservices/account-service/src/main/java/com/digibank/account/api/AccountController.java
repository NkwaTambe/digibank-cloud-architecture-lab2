package com.digibank.account.api;

import com.digibank.account.model.Account;
import com.digibank.account.service.AccountService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/accounts")
public class AccountController {

    private final AccountService service;

    public AccountController(AccountService service) {
        this.service = service;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Account create(@RequestBody Account account) {
        return service.createAccount(account);
    }

    @GetMapping("/{id}")
    public Account findById(@PathVariable Long id) {
        return service.getAccount(id);
    }

    @GetMapping
    public List<Account> findAll() {
        return service.getAccounts();
    }

    @PostMapping("/{id}/debit")
    public Account debit(@PathVariable Long id, @RequestBody AmountRequest request) {
        return service.debit(id, request.amount());
    }

    @PostMapping("/{id}/credit")
    public Account credit(@PathVariable Long id, @RequestBody AmountRequest request) {
        return service.credit(id, request.amount());
    }
}
