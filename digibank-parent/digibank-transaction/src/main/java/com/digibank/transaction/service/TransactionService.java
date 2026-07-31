package com.digibank.transaction.service;

import com.digibank.transaction.model.Transaction;
import jakarta.ejb.Stateless;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@Stateless
public class TransactionService {

    private static final List<Transaction> TRANSACTIONS = new ArrayList<>();

    public void addTransaction(Transaction transaction) {
        TRANSACTIONS.add(transaction);
    }

    public List<Transaction> getTransactions() {
        return Collections.unmodifiableList(TRANSACTIONS);
    }
}
