package com.example.offerservice.Model;

public enum OfferStatus {
    PENDING,
    AWAITING_PAYMENT, //marked done by runner
    PAID, //payment use offer client to mark as paid (optional)
    CANCELLED,
    ACCEPTED
}