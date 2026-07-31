package com.digibank.transaction.repository;

import com.digibank.transaction.model.Transaction;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;

/**
 * JPA-backed repository for Transaction entities.
 * Persists data to the 'transactions' table in digibank_db via the digibankPU unit.
 */
@Stateless
public class TransactionRepository {

    @PersistenceContext(unitName = "digibankPU")
    private EntityManager em;

    public void save(Transaction transaction) {
        em.persist(transaction);
    }

    public Transaction findById(Long id) {
        return em.find(Transaction.class, id);
    }

    public List<Transaction> findAll() {
        return em.createQuery("SELECT t FROM Transaction t", Transaction.class).getResultList();
    }
}
