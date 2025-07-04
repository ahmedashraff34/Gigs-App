package com.example.Dispute_Service.Service;
import com.example.Dispute_Service.Model.Dispute;
import com.example.Dispute_Service.Model.DisputeStatus;
import com.example.Dispute_Service.Repositry.DisputeRepository;
import com.example.Dispute_Service.Client.TaskClient;
import com.example.Dispute_Service.Client.UserClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class DisputeService {
    private static final Logger logger = LoggerFactory.getLogger(DisputeService.class);
    private static final int MAX_EVIDENCE_URLS = 5;

    private final DisputeRepository disputeRepository;
    private final TaskClient taskClient;
    private final UserClient userClient;

    @Autowired
    public DisputeService(DisputeRepository disputeRepository, TaskClient taskClient, UserClient userClient) {
        this.disputeRepository = disputeRepository;
        this.taskClient = taskClient;
        this.userClient = userClient;
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
}