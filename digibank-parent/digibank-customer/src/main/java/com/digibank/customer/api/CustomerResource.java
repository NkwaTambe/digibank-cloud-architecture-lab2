package com.digibank.customer.api;

import com.digibank.customer.model.Customer;
import com.digibank.customer.service.CustomerService;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/customers")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class CustomerResource {

    @Inject
    private CustomerService service;

    @POST
    public Response create(Customer customer) {
        service.createCustomer(customer);
        return Response.status(Response.Status.CREATED).entity(customer).build();
    }

    @GET
    @Path("/{id}")
    public Response findById(@PathParam("id") Long id) {
        Customer customer = service.getCustomer(id);
        if (customer == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        return Response.ok(customer).build();
    }

    @GET
    public Response findAll() {
        return Response.ok(service.getAllCustomers()).build();
    }
}
