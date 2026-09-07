package com.digibank.transaction.query;

import com.digibank.transaction.repository.TransactionRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TransactionQueryService {

    private final TransactionRepository repository;

    public TransactionQueryService(TransactionRepository repository) {
        this.repository = repository;
    }

    public List<TransactionView> getAllViews() {
        return repository.findAll()
                .stream()
                .map(transaction -> new TransactionView(
                        transaction.getId(),
                        transaction.getAccountId(),
                        transaction.getAmount(),
                        transaction.getType()))
                .toList();
    }
}
