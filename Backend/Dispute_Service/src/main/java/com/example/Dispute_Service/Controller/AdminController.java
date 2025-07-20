package com.example.Dispute_Service.Controller;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.example.Dispute_Service.DTO.AdminDisputeResolutionRequest;
import com.example.Dispute_Service.DTO.DisputeResponse;
import com.example.Dispute_Service.Model.Dispute;
import com.example.Dispute_Service.Service.DisputeService;

@RestController
@RequestMapping("/api/admin/disputes")
@CrossOrigin(origins = "http://localhost:5173")
public class AdminController {

    private final DisputeService disputeService;

    @Autowired
    public AdminController(DisputeService disputeService) {
        this.disputeService = disputeService;
    }

    /**
     * Get all disputes for admin dashboard
     */
    @GetMapping
    public ResponseEntity<List<DisputeResponse>> getAllDisputes() {
        try {
            List<DisputeResponse> disputes = disputeService.getAllDisputeResponses();
            return ResponseEntity.ok(disputes);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    /**
     * Get all pending disputes that need admin attention
     */
    @GetMapping("/pending")
    public ResponseEntity<List<DisputeResponse>> getPendingDisputes() {
        try {
            List<DisputeResponse> disputes = disputeService.getPendingDisputeResponses();
            return ResponseEntity.ok(disputes);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    /**
     * Get disputes raised by a specific user
     */
    @GetMapping("/user/{userId}/raised")
    public ResponseEntity<List<Dispute>> getDisputesRaisedByUser(@PathVariable Long userId) {
        try {
            List<Dispute> disputes = disputeService.getDisputesByUser(userId);
            return ResponseEntity.ok(disputes);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    /**
     * Get disputes against a specific user
     */
    @GetMapping("/user/{userId}/against")
    public ResponseEntity<List<Dispute>> getDisputesAgainstUser(@PathVariable Long userId) {
        try {
            List<Dispute> disputes = disputeService.getDisputesAgainstUser(userId);
            return ResponseEntity.ok(disputes);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    /**
     * Get specific dispute details for admin review
     */
    @GetMapping("/{disputeId}")
    public ResponseEntity<DisputeResponse> getDisputeDetails(@PathVariable Long disputeId) {
        try {
            DisputeResponse dispute = disputeService.getDisputeResponseById(disputeId);
            return ResponseEntity.ok(dispute);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    }

    /**
     * Admin resolves dispute with payment action (release or refund)
     */
    @PutMapping("/{disputeId}/resolve")
    public ResponseEntity<Map<String, Object>> resolveDispute(
            @PathVariable Long disputeId,
            @RequestBody AdminDisputeResolutionRequest request) {
        try {
            boolean success = disputeService.resolveDisputeWithPayment(disputeId, request);
            if (success) {
                Map<String, Object> response = Map.of(
                    "message", "Dispute resolved successfully with payment action: " + request.getResolutionType(),
                    "disputeId", disputeId,
                    "resolutionType", request.getResolutionType(),
                    "adminNotes", request.getAdminNotes()
                );
                return ResponseEntity.ok(response);
            } else {
                Map<String, Object> error = Map.of(
                    "error", "Failed to resolve dispute",
                    "disputeId", disputeId
                );
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
            }
        } catch (Exception e) {
            Map<String, Object> error = Map.of(
                "error", e.getMessage(),
                "disputeId", disputeId
            );
            return ResponseEntity.badRequest().body(error);
        }
    }

    /**
     * Get dispute statistics for admin dashboard
     */
    @GetMapping("/statistics")
    public ResponseEntity<Map<String, Object>> getDisputeStatistics() {
        try {
            List<Dispute> allDisputes = disputeService.getAllDisputes();
            List<Dispute> pendingDisputes = disputeService.getPendingDisputes();
            
            Map<String, Object> statistics = Map.of(
                "totalDisputes", allDisputes.size(),
                "pendingDisputes", pendingDisputes.size(),
                "resolvedDisputes", allDisputes.stream()
                    .filter(d -> d.getStatus().name().equals("RESOLVED"))
                    .count(),
                "closedDisputes", allDisputes.stream()
                    .filter(d -> d.getStatus().name().equals("CLOSED"))
                    .count()
            );
            
            return ResponseEntity.ok(statistics);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(null);
        }
    }

    /**
     * Debug endpoint to test payment service connection
     */
    @GetMapping("/debug/payment-test")
    public ResponseEntity<Map<String, Object>> testPaymentServiceConnection() {
        try {
            Map<String, Object> result = new HashMap<>();
            
            // Test refund payment (this should fail gracefully if no payment exists)
            try {
                ResponseEntity<String> refundResponse = disputeService.testRefundPayment(999L, 1L); // Test with non-existent task
                result.put("refundTest", Map.of(
                    "status", refundResponse.getStatusCode().toString(),
                    "body", refundResponse.getBody()
                ));
            } catch (Exception e) {
                result.put("refundTest", Map.of(
                    "error", e.getMessage(),
                    "type", e.getClass().getSimpleName()
                ));
            }
            
            // Test release payment (this should fail gracefully if no payment exists)
            try {
                ResponseEntity<String> releaseResponse = disputeService.testReleasePayment(999L, 1L); // Test with non-existent task
                result.put("releaseTest", Map.of(
                    "status", releaseResponse.getStatusCode().toString(),
                    "body", releaseResponse.getBody()
                ));
            } catch (Exception e) {
                result.put("releaseTest", Map.of(
                    "error", e.getMessage(),
                    "type", e.getClass().getSimpleName()
                ));
            }
            
            result.put("message", "Payment service connection test completed");
            result.put("timestamp", LocalDateTime.now());
            
            return ResponseEntity.ok(result);
        } catch (Exception e) {
            Map<String, Object> error = Map.of(
                "error", "Failed to test payment service connection: " + e.getMessage(),
                "timestamp", LocalDateTime.now()
            );
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
} 