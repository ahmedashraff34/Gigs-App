package com.example.Dispute_Service.Controller;
import com.example.Dispute_Service.DTO.CreateDisputeRequest;
import com.example.Dispute_Service.Model.Dispute;
import com.example.Dispute_Service.DTO.ResolutionRequest;
import com.example.Dispute_Service.DTO.AdminDisputeResolutionRequest;
import com.example.Dispute_Service.DTO.DisputeResponse;
import com.example.Dispute_Service.Service.DisputeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/disputes")
@CrossOrigin(origins = "http://localhost:5173")
public class DisputeController {

    private final DisputeService disputeService;

    @Autowired
    public DisputeController(DisputeService disputeService) {
        this.disputeService = disputeService;
    }

    // Create Dispute
    @PostMapping
    public ResponseEntity<Dispute> createDispute(
            @RequestBody CreateDisputeRequest request) {

        Dispute dispute = disputeService.createDispute(
                request.getTaskId(),
                request.getComplainantId(),
                request.getDefendantId(),
                request.getReason(),
                request.getEvidenceUris()
        );
        return ResponseEntity.ok(dispute);
    }

    // Get Dispute by ID
    @GetMapping("/{id}")
    public ResponseEntity<Dispute> getDisputeById(@PathVariable Long id) {
        Dispute dispute = disputeService.getDisputeById(id);
        if (dispute != null) {
            return ResponseEntity.ok(dispute);
        }
        return ResponseEntity.notFound().build();
    }

    // Resolve Dispute
    @PutMapping("/{id}/resolve")
    public ResponseEntity<String> resolveDispute(
            @PathVariable Long id,
            @RequestBody ResolutionRequest request) {
        boolean success = disputeService.resolveDispute(id, request.getResolution());
        if (success) {
            return ResponseEntity.ok("Dispute resolved.");
        }
        return ResponseEntity.notFound().build();
    }

    // Close Dispute
    @PutMapping("/{id}/close")
    public ResponseEntity<String> closeDispute(@PathVariable Long id) {
        boolean success = disputeService.closeDispute(id);
        if (success) {
            return ResponseEntity.ok("Dispute closed.");
        }
        return ResponseEntity.notFound().build();
    }
    @GetMapping
    public ResponseEntity<List<Dispute>> getAllDisputes() {
        List<Dispute> disputes = disputeService.getAllDisputes();
        return ResponseEntity.ok(disputes);
    }
    
    // ========== ADMIN ENDPOINTS ==========
    
    /**
     * Get all disputes with detailed information (Admin view)
     */
    @GetMapping("/admin/all")
    public ResponseEntity<List<DisputeResponse>> getAllDisputesForAdmin() {
        try {
            List<DisputeResponse> disputes = disputeService.getAllDisputeResponses();
            return ResponseEntity.ok(disputes);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(null);
        }
    }
    
    /**
     * Get all pending disputes for admin review
     */
    @GetMapping("/admin/pending")
    public ResponseEntity<List<DisputeResponse>> getPendingDisputesForAdmin() {
        try {
            List<DisputeResponse> disputes = disputeService.getPendingDisputeResponses();
            return ResponseEntity.ok(disputes);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(null);
        }
    }
    
    /**
     * Get disputes raised by a specific user
     */
    @GetMapping("/admin/user/{userId}/raised")
    public ResponseEntity<List<Dispute>> getDisputesRaisedByUser(@PathVariable Long userId) {
        try {
            List<Dispute> disputes = disputeService.getDisputesByUser(userId);
            return ResponseEntity.ok(disputes);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(null);
        }
    }
    
    /**
     * Get disputes against a specific user
     */
    @GetMapping("/admin/user/{userId}/against")
    public ResponseEntity<List<Dispute>> getDisputesAgainstUser(@PathVariable Long userId) {
        try {
            List<Dispute> disputes = disputeService.getDisputesAgainstUser(userId);
            return ResponseEntity.ok(disputes);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(null);
        }
    }
    
    /**
     * Admin resolves dispute with payment action (release or refund)
     */
    @PutMapping("/admin/{disputeId}/resolve-with-payment")
    public ResponseEntity<Map<String, Object>> resolveDisputeWithPayment(
            @PathVariable Long disputeId,
            @RequestBody AdminDisputeResolutionRequest request) {
        try {
            boolean success = disputeService.resolveDisputeWithPayment(disputeId, request);
            if (success) {
                Map<String, Object> response = Map.of(
                    "message", "Dispute resolved successfully with payment action: " + request.getResolutionType(),
                    "disputeId", disputeId,
                    "resolutionType", request.getResolutionType()
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
     * Get dispute details for admin view
     */
    @GetMapping("/admin/{disputeId}")
    public ResponseEntity<DisputeResponse> getDisputeForAdmin(@PathVariable Long disputeId) {
        try {
            DisputeResponse dispute = disputeService.getDisputeResponseById(disputeId);
            return ResponseEntity.ok(dispute);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(null);
        }
    }
}
