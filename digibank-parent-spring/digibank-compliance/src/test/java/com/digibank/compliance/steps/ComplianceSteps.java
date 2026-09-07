package com.digibank.compliance.steps;

import com.digibank.compliance.service.ComplianceService;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import org.junit.jupiter.api.Assertions;

public class ComplianceSteps {

    private final ComplianceService service = new ComplianceService();
    private Double amount;
    private boolean result;

    @Given("a transaction amount of {int}")
    public void aTransactionAmountOf(Integer amount) {
        this.amount = amount.doubleValue();
    }

    @When("the compliance check is performed")
    public void complianceCheckIsPerformed() {
        result = service.validateTransactionAmount(amount);
    }

    @Then("the transaction is accepted")
    public void theTransactionIsAccepted() {
        Assertions.assertTrue(result);
    }

    @Then("the transaction is rejected")
    public void theTransactionIsRejected() {
        Assertions.assertFalse(result);
    }
}
