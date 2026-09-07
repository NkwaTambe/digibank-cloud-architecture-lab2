package com.digibank.customer.api;

import com.digibank.customer.model.Customer;
import com.digibank.customer.service.CustomerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/customers")
@Tag(name = "Customers", description = "Endpoints for creating and consulting bank customers.")
public class CustomerController {

    private final CustomerService service;

    public CustomerController(CustomerService service) {
        this.service = service;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create a customer", description = "Registers a new customer and returns the persisted entity with its generated identifier.")
    public Customer create(@RequestBody Customer customer) {
        return service.createCustomer(customer);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Find customer by id", description = "Returns a single customer matching the supplied identifier, or a 404 when not found.")
    public Customer findById(@PathVariable Long id) {
        return service.getCustomer(id);
    }

    @GetMapping
    @Operation(summary = "List all customers", description = "Returns the full list of registered customers.")
    public List<Customer> findAll() {
        return service.getCustomers();
    }
}
