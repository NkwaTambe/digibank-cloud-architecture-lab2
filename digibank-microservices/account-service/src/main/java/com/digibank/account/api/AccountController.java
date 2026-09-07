package com.digibank.account.api;

import com.digibank.account.model.Account;
import com.digibank.account.service.AccountService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
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
@Tag(name = "Accounts", description = "Endpoints for account creation, balance consultation, debit and credit operations.")
public class AccountController {

    private final AccountService service;

    public AccountController(AccountService service) {
        this.service = service;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create an account", description = "Registers a new bank account with an opening balance.")
    public Account create(@RequestBody Account account) {
        return service.createAccount(account);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Find account by id", description = "Returns a single account matching the supplied identifier, or a 404 when not found.")
    public Account findById(@PathVariable Long id) {
        return service.getAccount(id);
    }

    @GetMapping
    @Operation(summary = "List all accounts", description = "Returns the full list of accounts.")
    public List<Account> findAll() {
        return service.getAccounts();
    }

    @PostMapping("/{id}/debit")
    @Operation(summary = "Debit an account", description = "Decreases the account balance by the supplied amount.")
    public Account debit(@PathVariable Long id, @RequestBody AmountRequest request) {
        return service.debit(id, request.amount());
    }

    @PostMapping("/{id}/credit")
    @Operation(summary = "Credit an account", description = "Increases the account balance by the supplied amount.")
    public Account credit(@PathVariable Long id, @RequestBody AmountRequest request) {
        return service.credit(id, request.amount());
    }
}
