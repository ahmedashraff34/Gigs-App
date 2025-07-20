package com.gigs.payment_service.controller;

import com.gigs.payment_service.dto.request.PaymentRequest;
import com.gigs.payment_service.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {

    private final PaymentService paymentService;

    @Autowired
    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    @PostMapping("/process")
    public ResponseEntity<String> processPayment(@RequestBody PaymentRequest request) {
        boolean success = paymentService.processPayment(request);
        if (success) {
            return ResponseEntity.ok("Payment processed successfully.");
        } else {
            return ResponseEntity.badRequest().body("Payment processing failed." + request);
        }
    }

    @PostMapping("/release/{taskId}")
    public ResponseEntity<String> releasePayment(@PathVariable Long taskId,@RequestParam Long recipient) {
        boolean success = paymentService.releasePayment(taskId,recipient);
        if (success) {
            return ResponseEntity.ok("Payment released successfully.");
        } else {
            return ResponseEntity.badRequest().body("Payment release failed.");
        }
    }

    @PostMapping("/refund/{taskId}")
    public ResponseEntity<String> refundPayment(@PathVariable Long taskId,@RequestParam Long recipient) {
        boolean success = paymentService.refundPayment(taskId,recipient);
        if (success) {
            return ResponseEntity.ok("Payment refunded successfully.");
        } else {
            return ResponseEntity.badRequest().body("Payment refund failed.");
        }
    }
}
