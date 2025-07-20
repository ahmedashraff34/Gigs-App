package com.example.Dispute_Service.Client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(name = "payment-service")
public interface PaymentClient {

    @PostMapping(value = "/api/payments/release/{taskId}")
    ResponseEntity<String> releasePayment(
            @PathVariable("taskId") Long taskId, 
            @RequestParam Long recipient);

    @PostMapping(value = "/api/payments/refund/{taskId}")
    ResponseEntity<String> refundPayment(@PathVariable("taskId") Long taskId,
                                         @RequestParam Long recipient);
} 