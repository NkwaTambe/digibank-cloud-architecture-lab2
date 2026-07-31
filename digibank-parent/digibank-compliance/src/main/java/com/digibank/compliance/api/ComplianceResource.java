package com.digibank.compliance.api;

import com.digibank.compliance.service.ComplianceService;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/compliance")
@Produces(MediaType.APPLICATION_JSON)
public class ComplianceResource {

    @Inject
    private ComplianceService service;

    @GET
    @Path("/validate/{amount}")
    public Response validate(@PathParam("amount") Double amount) {
        boolean valid = service.validateTransactionAmount(amount);
        return Response.ok("{\"valid\":" + valid + "}").build();
    }
}
