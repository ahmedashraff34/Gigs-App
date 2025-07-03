package com.gigs.payment_service.model;

public enum PaymentStatus {
    PENDING,
    COMPLETED,
    FAILED,
    RELEASED,
    HELD,
    REFUNDED;

//    public boolean canTransitionTo(PaymentStatus newStatus) {
//        return switch (this) {
//            case PENDING -> newStatus == COMPLETED || newStatus == CANCELLED;
//            case IN_PROGRESS -> newStatus == COMPLETED;
//            case COMPLETED, CANCELLED -> false; // No further updates allowed
//        };
//    }

}

