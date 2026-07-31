package com.digibank.transaction.service;

import com.digibank.transaction.model.Transaction;
import com.digibank.transaction.repository.TransactionRepository;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import java.util.List;

@Stateless
public class TransactionService {

    @Inject
    private TransactionRepository repository;

    public void addTransaction(Transaction transaction) {
        repository.save(transaction);
    }

    public Transaction getTransaction(Long id) {
        return repository.findById(id);
    }

    public List<Transaction> getTransactions() {
        return repository.findAll();
    }
}
