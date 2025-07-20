package com.gigs.task_service.client.payment;

import com.gigs.task_service.client.payment.PaymentClient;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@FeignClient(name = "payment-service")
public interface PaymentClient {

    @PostMapping(value = "/api/payments/process")
    ResponseEntity<String> processPayment(@RequestBody PaymentRequest request);

    @PostMapping(value = "/api/payments/release/{taskId}")
    ResponseEntity<String> releasePayment(@PathVariable("taskId") Long taskId, @RequestParam Long recipient);

    @PostMapping(value = "/api/payments/refund/{taskId}")
    ResponseEntity<String> refundPayment(@PathVariable("taskId") Long taskId, @RequestParam Long recipient);
}
