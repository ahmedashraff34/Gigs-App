package com.gigs.payment_service.repository;

import com.gigs.payment_service.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PaymentRepository extends JpaRepository<Payment, Long> {
    Payment findByTaskIdAndRecipient(Long taskId, Long recipient);
    Payment findByTaskId(Long taskId);
}
