package com.digibank.transaction.api;

import com.digibank.transaction.model.Transaction;
import com.digibank.transaction.service.TransactionService;
import jakarta.inject.Inject;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/transactions")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class TransactionResource {

    @Inject
    private TransactionService service;

    @POST
    public Response create(Transaction transaction) {
        service.addTransaction(transaction);
        return Response.status(Response.Status.CREATED).entity(transaction).build();
    }

    @GET
    public Response findAll() {
        return Response.ok(service.getTransactions()).build();
    }
}
