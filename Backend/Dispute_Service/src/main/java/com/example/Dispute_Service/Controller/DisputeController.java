package com.example.Dispute_Service.Controller;
import com.example.Dispute_Service.DTO.CreateDisputeRequest;
import com.example.Dispute_Service.Model.Dispute;
import com.example.Dispute_Service.DTO.ResolutionRequest;
import com.example.Dispute_Service.Service.DisputeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/disputes")
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
}
