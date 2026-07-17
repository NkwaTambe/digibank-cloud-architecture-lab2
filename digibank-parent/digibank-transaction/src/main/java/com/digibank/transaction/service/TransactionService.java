package com.digibank.transaction.service;

import com.digibank.transaction.model.Transaction;
import jakarta.ejb.Stateless;
import java.util.ArrayList;
import java.util.List;

@Stateless
public class TransactionService {

    private static final List<Transaction> transactions = new ArrayList<>();

    public void addTransaction(Transaction transaction) {
        transactions.add(transaction);
    }

    public List<Transaction> getTransactions() {
        return transactions;
    }
}
