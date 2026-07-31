package com.digibank.account.repository;

import com.digibank.account.model.Account;
import jakarta.ejb.Stateless;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import java.util.List;
import java.util.Optional;

/**
 * JPA-backed repository for Account entities.
 * Persists data to the 'accounts' table in digibank_db via the digibankPU unit.
 */
@Stateless
public class AccountRepository {

    @PersistenceContext(unitName = "digibankPU")
    private EntityManager em;

    public void save(Account account) {
        em.persist(account);
    }

    public Account findById(Long id) {
        return em.find(Account.class, id);
    }

    public Optional<Account> findByAccountNumber(String accountNumber) {
        return em.createQuery(
                "SELECT a FROM Account a WHERE a.accountNumber = :num", Account.class)
                .setParameter("num", accountNumber)
                .getResultStream()
                .findFirst();
    }

    public List<Account> findAll() {
        return em.createQuery("SELECT a FROM Account a", Account.class).getResultList();
    }
}
