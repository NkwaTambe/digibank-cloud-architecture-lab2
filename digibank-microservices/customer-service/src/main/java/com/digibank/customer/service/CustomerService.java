package com.digibank.customer.service;

import com.digibank.customer.model.Customer;
import com.digibank.customer.repository.CustomerRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CustomerService {

    private final CustomerRepository repository;

    public CustomerService(CustomerRepository repository) {
        this.repository = repository;
    }

    public Customer createCustomer(Customer customer) {
        return repository.save(customer);
    }

    public Customer getCustomer(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Customer not found: " + id));
    }

    public List<Customer> getCustomers() {
        return repository.findAll();
    }
}
