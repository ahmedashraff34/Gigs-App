package com.gigs.payment_service.service;

import com.gigs.payment_service.dto.request.PaymentRequest;
import com.gigs.payment_service.processor.PaymentProcessor;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service

public class PaymentService {

    private final PaymentProcessor paymentProcessor;
    @Autowired
    public PaymentService(PaymentProcessor paymentProcessor) {
        this.paymentProcessor = paymentProcessor;
    }

    public boolean processPayment(PaymentRequest request) {
        return paymentProcessor.processPayment(request);
    }

    public boolean releasePayment(Long taskId, Long recipient) {
        return paymentProcessor.releasePayment(taskId,recipient);
    }

    public boolean refundPayment(Long taskId) {
        return paymentProcessor.refundPayment(taskId);
    }

}
