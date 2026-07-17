package com.digibank.customer.service;

import com.digibank.customer.model.Customer;
import com.digibank.customer.repository.CustomerRepository;
import jakarta.ejb.Stateless;
import jakarta.inject.Inject;
import java.util.List;

@Stateless
public class CustomerService {

    @Inject
    private CustomerRepository repository;

    public void createCustomer(Customer customer) {
        repository.save(customer);
    }

    public Customer getCustomer(Long id) {
        return repository.findById(id);
    }

    public List<Customer> getAllCustomers() {
        return repository.findAll();
    }
}
