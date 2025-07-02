package com.example.eventservice.model;

public enum ApplicationStatus {
    PENDING,            // Applied but not yet approved
    APPROVED,           // Chosen to participate
    WITHDRAWN,          // Approved but later canceled or didn't attend
    AWAITING_PAYMENT,   // Attended, waiting to get paid
    PAID                // Fully completed and paid
}
