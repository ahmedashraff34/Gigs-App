package com.gigs.payment_service.processor;

import com.gigs.payment_service.client.TaskClient;
import com.gigs.payment_service.client.UserClient;
import com.gigs.payment_service.dto.request.PaymentRequest;
import com.gigs.payment_service.dto.response.PaymentResponse;
import com.gigs.payment_service.model.Payment;
import com.gigs.payment_service.model.PaymentStatus;
import com.gigs.payment_service.repository.PaymentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.scheduling.config.Task;
import org.springframework.stereotype.Component;

@Component
public class EscrowPaymentProcessor implements PaymentProcessor {


    TaskClient taskClient;
    UserClient userClient;
    PaymentRepository paymentRepo;

    @Autowired
    public EscrowPaymentProcessor(TaskClient taskClient, UserClient userClient,PaymentRepository paymentRepo) {
        this.taskClient = taskClient;
        this.userClient = userClient;
        this.paymentRepo = paymentRepo;
    }
    public boolean validatePayment(PaymentRequest paymentRequest) {
        if (paymentRequest == null) {
            System.err.println("Payment request is null.");
            return false;
        }

        if(paymentRequest.getAmount()<=0 || paymentRequest.getPayer() == 0L
                || paymentRequest.getRecipient()==0L || paymentRequest.getTaskId() == 0L){
            return false;
        }
        
//        //34an lw already l task processes fa n avoid duplication w kda
//        if (paymentRepo.findByTaskId(paymentRequest.getTaskId()) != null) {
//            System.err.println("An escrow payment already exists for this task ID: " + paymentRequest.getTaskId());
//            return false;
//        }

        if(paymentRequest.getPayer()==paymentRequest.getRecipient()) return false;
        try{
        ResponseEntity<Boolean> flag=taskClient.verifyParticipantsAndStatus(paymentRequest.getTaskId(), paymentRequest.getPayer(), paymentRequest.getRecipient());
            if (!flag.getStatusCode().is2xxSuccessful() || Boolean.FALSE.equals(flag.getBody())) {
                return false;
            }

        }catch (Exception e){
            System.err.println("Payment validation error: "+ e.getMessage());
            return false;
        }

        return  true;
    }
    @Override
    public boolean processPayment(PaymentRequest payment) {
        if(validatePayment(payment)){
            try{
                userClient.deductAmount(payment.getPayer(), payment.getAmount());
                Payment p = new Payment();
                p.setAmount(payment.getAmount());
                p.setPayer(payment.getPayer());
                p.setRecipient(payment.getRecipient());
                p.setTaskId(payment.getTaskId());
                p.setStatus(PaymentStatus.PENDING);
                paymentRepo.save(p);
                return true;

            }catch(Exception e){
                System.err.println("Error while deducting amount from task poster with ID: " + payment.getPayer());
                return false;
            }

        }
        return false;
    }
    @Override
    public boolean releasePayment(Long taskId, Long recipient) {
        Payment payment = paymentRepo.findByTaskIdAndRecipient(taskId, recipient);
        if (payment == null) {
            System.err.println("No payment found for task ID: " + taskId + " and recipient ID: " + recipient);
            return false;
        }

        if (payment.getStatus() != PaymentStatus.PENDING && payment.getStatus() != PaymentStatus.HELD) {
            System.err.println("Payment is not in PENDING or HELD state. Cannot release again.");
            return false;
        }

        try {
            // Transfer the amount to the recipient
            userClient.addAmount(payment.getRecipient(), payment.getAmount());

            // Update the payment status
            payment.setStatus(PaymentStatus.COMPLETED);
            paymentRepo.save(payment);
            return true;
        } catch (Exception e) {
            System.err.println("Error while transferring amount to recipient with ID: " + payment.getRecipient());
            return false;
        }
    }

    @Override
    public boolean refundPayment(Long taskId) {
        Payment payment = paymentRepo.findByTaskId(taskId);
        if (payment == null) {
            System.err.println("No payment found for task ID: " + taskId);
            return false;
        }

        if (payment.getStatus() != PaymentStatus.PENDING || payment.getStatus() != PaymentStatus.HELD) {
            System.err.println("Payment is not in PENDING or HELD state. Cannot refund again.");
            return false;
        }
        try{
            userClient.addAmount(payment.getPayer(), payment.getAmount());
            payment.setStatus(PaymentStatus.REFUNDED);
            paymentRepo.save(payment);
            return true;

        }catch(Exception e){
            System.err.println("Error while refunding amount to task poster with ID: " + payment.getPayer());
            return false;
        }

    }
}

