package com.digibank.transaction.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.Map;

@FeignClient(name = "account-service", path = "/accounts")
public interface AccountClient {

    @PostMapping("/{id}/debit")
    void debit(@PathVariable Long id, @RequestBody Map<String, Object> request);

    @PostMapping("/{id}/credit")
    void credit(@PathVariable Long id, @RequestBody Map<String, Object> request);
}
