package com.digibank.transaction.command;

import com.digibank.transaction.model.Transaction;
import com.digibank.transaction.repository.TransactionRepository;
import org.springframework.stereotype.Service;

@Service
public class TransactionCommandHandler {

    private final TransactionRepository repository;

    public TransactionCommandHandler(TransactionRepository repository) {
        this.repository = repository;
    }

    public Transaction handle(CreateTransactionCommand command) {
        Transaction transaction = new Transaction(command.accountId(), command.amount(), command.type());
        return repository.save(transaction);
    }
}
