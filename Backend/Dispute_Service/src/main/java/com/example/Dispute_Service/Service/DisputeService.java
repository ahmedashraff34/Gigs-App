package com.example.Dispute_Service.Service;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.server.ResponseStatusException;

import com.example.Dispute_Service.Client.PaymentClient;
import com.example.Dispute_Service.Client.TaskClient;
import com.example.Dispute_Service.Client.UserClient;
import com.example.Dispute_Service.DTO.AdminDisputeResolutionRequest;
import com.example.Dispute_Service.DTO.DisputeResponse;
import com.example.Dispute_Service.Model.Dispute;
import com.example.Dispute_Service.Model.DisputeStatus;
import com.example.Dispute_Service.Repositry.DisputeRepository;

@Service
public class DisputeService {
    private static final Logger logger = LoggerFactory.getLogger(DisputeService.class);
    private static final int MAX_EVIDENCE_URLS = 5;

    private final DisputeRepository disputeRepository;
    private final TaskClient taskClient;
    private final UserClient userClient;
    private final PaymentClient paymentClient;

    @Autowired
    public DisputeService(DisputeRepository disputeRepository, TaskClient taskClient, UserClient userClient, PaymentClient paymentClient) {
        this.disputeRepository = disputeRepository;
        this.taskClient = taskClient;
        this.userClient = userClient;
        this.paymentClient = paymentClient;
    }

    public Dispute createDispute(Long taskId, Long complainantId, Long defendantId, String reason, List<String> evidenceUris) {
        logger.info("Creating dispute for taskId: {}, complainantId: {}, defendantId: {}", taskId, complainantId, defendantId);
        
        // Input validation
        validateInput(taskId, complainantId, defendantId, reason, evidenceUris);

        // Validate task existence
        Boolean taskExists = taskClient.existsById(taskId);
        if (taskExists == null || !taskExists) {
            logger.error("Task with ID {} does not exist", taskId);
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, 
                String.format("Task with ID %d does not exist", taskId));
        }

        // Validate complainant existence
        Boolean complainantExists = userClient.existsById(complainantId);
        if (complainantExists == null || !complainantExists) {
            logger.error("Complainant with ID {} does not exist", complainantId);
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, 
                String.format("Complainant with ID %d does not exist", complainantId));
        }

        // Validate defendant existence
        Boolean defendantExists = userClient.existsById(defendantId);
        if (defendantExists == null || !defendantExists) {
            logger.error("Defendant with ID {} does not exist", defendantId);
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, 
                String.format("Defendant with ID %d does not exist", defendantId));
        }

        // Create dispute if all validations pass
        Dispute dispute = new Dispute();
        dispute.setTaskId(taskId);
        dispute.setRaisedBy(complainantId);
        dispute.setDefendantId(defendantId);
        dispute.setReason(reason);
        dispute.setImages(String.join(",", evidenceUris));
        dispute.setStatus(DisputeStatus.PENDING);
        dispute.setCreatedAt(LocalDateTime.now());

        try {
            Dispute savedDispute = disputeRepository.save(dispute);
            logger.info("Successfully created dispute with ID: {}", savedDispute.getDisputeId());
            return savedDispute;
        } catch (Exception e) {
            logger.error("Failed to save dispute: {}", e.getMessage());
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, 
                "Failed to create dispute due to database error");
        }
    }

    private void validateInput(Long taskId, Long complainantId, Long defendantId, String reason, List<String> evidenceUris) {
        // Validate taskId
        if (taskId == null || taskId <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid task ID");
        }

        // Validate user IDs
        if (complainantId == null || complainantId <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid complainant ID");
        }
        if (defendantId == null || defendantId <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid defendant ID");
        }

        // Validate complainant and defendant are different
        if (complainantId.equals(defendantId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, 
                "Complainant and defendant cannot be the same user");
        }

        // Validate reason
        if (!StringUtils.hasText(reason)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Reason cannot be empty");
        }

        // Validate evidence URLs
        if (evidenceUris != null && evidenceUris.size() > MAX_EVIDENCE_URLS) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                    String.format("Maximum %d evidence URLs allowed", MAX_EVIDENCE_URLS));
        }
        if (evidenceUris != null) {
            for (String url : evidenceUris) {
                if (!isValidUrl(url)) {
                    throw new ResponseStatusException(HttpStatus.BAD_REQUEST,
                            String.format("Invalid evidence URL: %s", url));
                }
            }
        }
    }

    private boolean isValidUrl(String url) {
        try {
            new java.net.URL(url);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public Dispute getDisputeById(Long disputeId) {
        logger.info("Fetching dispute with ID: {}", disputeId);
        return disputeRepository.findById(disputeId)
                .orElseThrow(() -> {
                    logger.error("Dispute with ID {} not found", disputeId);
                    return new ResponseStatusException(HttpStatus.NOT_FOUND, 
                        String.format("Dispute with ID %d not found", disputeId));
                });
    }

    public boolean resolveDispute(Long disputeId, String resolution) {
        logger.info("Resolving dispute with ID: {}", disputeId);
        if (!StringUtils.hasText(resolution)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Resolution cannot be empty");
        }

        Dispute dispute = getDisputeById(disputeId);
        dispute.setStatus(DisputeStatus.RESOLVED);
        try {
            disputeRepository.save(dispute);
            logger.info("Successfully resolved dispute with ID: {}", disputeId);
            return true;
        } catch (Exception e) {
            logger.error("Failed to resolve dispute: {}", e.getMessage());
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, 
                "Failed to resolve dispute due to database error");
        }
    }

    public boolean closeDispute(Long disputeId) {
        logger.info("Closing dispute with ID: {}", disputeId);
        Dispute dispute = getDisputeById(disputeId);
        dispute.setStatus(DisputeStatus.CLOSED);
        try {
            disputeRepository.save(dispute);
            logger.info("Successfully closed dispute with ID: {}", disputeId);
            return true;
        } catch (Exception e) {
            logger.error("Failed to close dispute: {}", e.getMessage());
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, 
                "Failed to close dispute due to database error");
        }
    }

    public List<Dispute> getAllDisputes() {
        return disputeRepository.findAll();
    }
    
    /**
     * Get all disputes raised by a specific user
     */
    public List<Dispute> getDisputesByUser(Long userId) {
        logger.info("Fetching disputes for user ID: {}", userId);
        return disputeRepository.findByRaisedBy(userId);
    }
    
    /**
     * Get all disputes where user is the defendant
     */
    public List<Dispute> getDisputesAgainstUser(Long userId) {
        logger.info("Fetching disputes against user ID: {}", userId);
        return disputeRepository.findByDefendantId(userId);
    }
    
    /**
     * Get all pending disputes for admin review
     */
    public List<Dispute> getPendingDisputes() {
        logger.info("Fetching all pending disputes for admin review");
        return disputeRepository.findByStatus(DisputeStatus.PENDING);
    }
    
    /**
     * Admin resolves dispute with payment action (release or refund)
     */
    public boolean resolveDisputeWithPayment(Long disputeId, AdminDisputeResolutionRequest request) {
        logger.info("Admin resolving dispute with ID: {} with resolution type: {}", disputeId, request.getResolutionType());
        
        if (request.getResolutionType() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Resolution type is required");
        }
        
        Dispute dispute = getDisputeById(disputeId);
        
        // Check if dispute is in pending status
        if (dispute.getStatus() != DisputeStatus.PENDING) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, 
                "Can only resolve disputes that are in PENDING status. Current status: " + dispute.getStatus());
        }
        
        try {
            boolean paymentSuccess = false;
            String paymentAction = "";
            
            switch (request.getResolutionType()) {
                case RELEASE:
                    if (request.getRecipientId() == null) {
                        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, 
                            "Recipient ID is required for RELEASE resolution");
                    }
                    paymentAction = "RELEASE to recipient ID: " + request.getRecipientId();
                    paymentSuccess = releasePaymentForDispute(dispute.getTaskId(), request.getRecipientId());
                    break;
                    
                case REFUND:
                    if (request.getRecipientId() == null) {
                        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, 
                            "Recipient ID is required for REFUND resolution");
                    }
                    paymentAction = "REFUND to recipient ID: " + request.getRecipientId();
                    paymentSuccess = refundPaymentForDispute(dispute.getTaskId(), request.getRecipientId());
                    break;
                    
                default:
                    throw new ResponseStatusException(HttpStatus.BAD_REQUEST, 
                        "Invalid resolution type: " + request.getResolutionType());
            }
            
            if (paymentSuccess) {
                // Update dispute status and add admin notes
                dispute.setStatus(DisputeStatus.RESOLVED);
                dispute.setAdminNotes(request.getAdminNotes());
                disputeRepository.save(dispute);
                
                logger.info("Successfully resolved dispute with ID: {} with payment action: {}", 
                    disputeId, paymentAction);
                return true;
            } else {
                String errorMsg = String.format("Payment action failed for dispute ID: %d. Action: %s. Task ID: %d", 
                    disputeId, paymentAction, dispute.getTaskId());
                logger.error(errorMsg);
                throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, errorMsg);
            }
            
        } catch (ResponseStatusException e) {
            // Re-throw ResponseStatusException as-is
            throw e;
        } catch (Exception e) {
            String errorMsg = String.format("Failed to resolve dispute ID: %d. Error: %s", disputeId, e.getMessage());
            logger.error(errorMsg, e);
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, errorMsg);
        }
    }
    
    /**
     * Release payment for a dispute
     */
    private boolean releasePaymentForDispute(Long taskId, Long recipientId) {
        try {
            logger.info("Attempting to release payment for task ID: {} to recipient ID: {}", taskId, recipientId);
            
            var response = paymentClient.releasePayment(taskId, recipientId);
            
            logger.info("Payment release response status: {}", response.getStatusCode());
            logger.info("Payment release response body: {}", response.getBody());
            
            if (response.getStatusCode().is2xxSuccessful()) {
                logger.info("Successfully released payment for task ID: {} to recipient ID: {}", taskId, recipientId);
                return true;
            } else {
                logger.error("Payment release failed for task ID: {} to recipient ID: {}. Status: {}, Body: {}", 
                    taskId, recipientId, response.getStatusCode(), response.getBody());
                return false;
            }
        } catch (Exception e) {
            logger.error("Exception occurred while releasing payment for task ID: {} and recipient ID: {}", 
                taskId, recipientId, e);
            return false;
        }
    }
    
    /**
     * Refund payment for a dispute
     */
    private boolean refundPaymentForDispute(Long taskId, Long recipientId) {
        try {
            logger.info("Attempting to refund payment for task ID: {} to recipient ID: {}", taskId, recipientId);
            
            var response = paymentClient.refundPayment(taskId, recipientId);
            
            logger.info("Payment refund response status: {}", response.getStatusCode());
            logger.info("Payment refund response body: {}", response.getBody());
            
            if (response.getStatusCode().is2xxSuccessful()) {
                logger.info("Successfully refunded payment for task ID: {} to recipient ID: {}", taskId, recipientId);
                return true;
            } else {
                logger.error("Payment refund failed for task ID: {} to recipient ID: {}. Status: {}, Body: {}", 
                    taskId, recipientId, response.getStatusCode(), response.getBody());
                return false;
            }
        } catch (Exception e) {
            logger.error("Exception occurred while refunding payment for task ID: {} to recipient ID: {}", taskId, recipientId, e);
            return false;
        }
    }
    
    /**
     * Get dispute response with additional information
     */
    public DisputeResponse getDisputeResponseById(Long disputeId) {
        Dispute dispute = getDisputeById(disputeId);
        return DisputeResponse.fromDispute(dispute);
    }
    
    /**
     * Get all disputes as response DTOs
     */
    public List<DisputeResponse> getAllDisputeResponses() {
        return disputeRepository.findAll()
                .stream()
                .map(DisputeResponse::fromDispute)
                .collect(Collectors.toList());
    }
    
    /**
     * Get pending disputes as response DTOs
     */
    public List<DisputeResponse> getPendingDisputeResponses() {
        return disputeRepository.findByStatus(DisputeStatus.PENDING)
                .stream()
                .map(DisputeResponse::fromDispute)
                .collect(Collectors.toList());
    }

    /**
     * Test method to check payment service connection for refund
     */
    public ResponseEntity<String> testRefundPayment(Long taskId, Long recipientId) {
        try {
            logger.info("Testing refund payment for task ID: {} to recipient ID: {}", taskId, recipientId);
            return paymentClient.refundPayment(taskId, recipientId);
        } catch (Exception e) {
            logger.error("Test refund payment failed for task ID: {} to recipient ID: {}", taskId, recipientId, e);
            throw new RuntimeException("Test refund payment failed: " + e.getMessage(), e);
        }
    }
    
    /**
     * Test method to check payment service connection for release
     */
    public ResponseEntity<String> testReleasePayment(Long taskId, Long recipientId) {
        try {
            logger.info("Testing release payment for task ID: {} to recipient ID: {}", taskId, recipientId);
            return paymentClient.releasePayment(taskId, recipientId);
        } catch (Exception e) {
            logger.error("Test release payment failed for task ID: {} to recipient ID: {}", taskId, recipientId, e);
            throw new RuntimeException("Test release payment failed: " + e.getMessage(), e);
        }
    }
}