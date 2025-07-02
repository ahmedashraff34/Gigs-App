package com.gigs.payment_service.processor;

import com.gigs.payment_service.dto.request.PaymentRequest;
import com.gigs.payment_service.model.Payment;

public interface PaymentProcessor {
    public boolean processPayment(PaymentRequest payment);
    public boolean refundPayment(Long taskId);
    public boolean releasePayment(Long taskId, Long recipient);
}
