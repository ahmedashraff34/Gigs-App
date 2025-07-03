package com.gigs.task_service.client.payment;

import com.gigs.task_service.client.payment.PaymentClient;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@FeignClient(name = "payment-service", path = "/api/payments")
public interface PaymentClient {

    @PostMapping("/process")
    ResponseEntity<String> processPayment(@RequestBody PaymentRequest request);

    @PostMapping("/release/{taskId}")
    ResponseEntity<String> releasePayment(@PathVariable("taskId") Long taskId, @RequestParam Long recipient);

    @PostMapping("/refund/{taskId}")
    ResponseEntity<String> refundPayment(@PathVariable("taskId") Long taskId);
}
