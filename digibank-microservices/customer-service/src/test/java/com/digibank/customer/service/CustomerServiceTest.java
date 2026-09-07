package com.digibank.customer.service;

import com.digibank.customer.model.Customer;
import com.digibank.customer.repository.CustomerRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CustomerServiceTest {

    @Mock
    private CustomerRepository repository;

    @InjectMocks
    private CustomerService service;

    @Test
    void createsCustomerThroughRepository() {
        Customer customer = new Customer("Alice", "Smith", "alice.smith@digibank.com");
        when(repository.save(customer)).thenReturn(customer);

        Customer saved = service.createCustomer(customer);

        assertThat(saved.getEmail()).isEqualTo("alice.smith@digibank.com");
    }

    @Test
    void listsCustomersFromRepository() {
        when(repository.findAll()).thenReturn(List.of(new Customer("Bob", "Jones", "bob.jones@digibank.com")));

        List<Customer> customers = service.getCustomers();

        assertThat(customers).hasSize(1);
        assertThat(customers.get(0).getFirstName()).isEqualTo("Bob");
    }
}
