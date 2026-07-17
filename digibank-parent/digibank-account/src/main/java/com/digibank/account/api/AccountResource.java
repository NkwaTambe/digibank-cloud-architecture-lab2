package com.digibank.account.api;

import com.digibank.account.model.Account;
import com.digibank.account.service.AccountService;
import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/accounts")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class AccountResource {

    @Inject
    private AccountService service;

    @POST
    public Response create(Account account) {
        service.createAccount(account);
        return Response.status(Response.Status.CREATED).entity(account).build();
    }

    @GET
    public Response findAll() {
        return Response.ok(service.getAccounts()).build();
    }
}
