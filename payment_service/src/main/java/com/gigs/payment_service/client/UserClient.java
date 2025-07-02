package com.gigs.payment_service.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(name = "user-service")
public interface UserClient {

    @PutMapping("api/user/{id}/add-balance")
    ResponseEntity<String> addAmount(
            @PathVariable("id") Long id,
            @RequestParam("amount") double amount
    );

    @PutMapping("api/user/{id}/deduct-balance")
    ResponseEntity<String> deductAmount(
            @PathVariable("id") Long id,
            @RequestParam("amount") double amount
    );
}


