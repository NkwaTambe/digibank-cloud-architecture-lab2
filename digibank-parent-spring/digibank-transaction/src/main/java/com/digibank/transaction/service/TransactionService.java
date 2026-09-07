package com.digibank.transaction.service;

import com.digibank.transaction.model.Transaction;
import com.digibank.transaction.repository.TransactionRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class TransactionService {

    private final TransactionRepository repository;

    public TransactionService(TransactionRepository repository) {
        this.repository = repository;
    }

    public Transaction addTransaction(Transaction transaction) {
        return repository.save(transaction);
    }

    public Optional<Transaction> getTransaction(Long id) {
        return repository.findById(id);
    }

    public List<Transaction> getTransactions() {
        return repository.findAll();
    }
}
