package com.digibank.customer.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "customers")
@Schema(name = "Customer", description = "A bank customer holding one or more accounts.")
public class Customer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Schema(description = "Unique customer identifier.", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    private Long id;

    @Column(nullable = false)
    @Schema(description = "Customer first name.", example = "Alice", requiredMode = Schema.RequiredMode.REQUIRED)
    private String firstName;

    @Column(nullable = false)
    @Schema(description = "Customer last name.", example = "Smith", requiredMode = Schema.RequiredMode.REQUIRED)
    private String lastName;

    @Column(nullable = false, unique = true)
    @Schema(description = "Unique customer email address.", example = "alice.smith@digibank.com", requiredMode = Schema.RequiredMode.REQUIRED)
    private String email;

    public Customer() {
    }

    public Customer(String firstName, String lastName, String email) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
    }

    public Long getId() {
        return id;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
}
