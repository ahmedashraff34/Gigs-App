package com.gigs.task_service.client.payment;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentRequest {
    private long payer;
    private long recipient;
    private long taskId;
    private long amount;
}

