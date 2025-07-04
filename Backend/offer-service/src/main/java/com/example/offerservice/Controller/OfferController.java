package com.example.offerservice.Controller;

import com.example.offerservice.DTO.request.OfferRequest;
import com.example.offerservice.DTO.response.OfferResponse;
import com.example.offerservice.DTO.response.TaskResponse;
import com.example.offerservice.Model.OfferStatus;
import com.example.offerservice.Service.OfferService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;



import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/offers")
public class OfferController {

    private final OfferService offerService ;

    @Autowired
    public OfferController(OfferService offerService) {
        this.offerService = offerService;
    }

    // Get all offers for a given task
    @GetMapping("/task/{taskId}")
    public ResponseEntity<List<OfferResponse>> getOffersForTask(@PathVariable Long taskId) {
        List<OfferResponse> offers = offerService.getOffersForTask(taskId);
        return ResponseEntity.ok(offers);
    }

    // Place a new offer
    @PostMapping
    public ResponseEntity<?> placeOffer(@RequestBody OfferRequest request) {
        boolean success = offerService.validateAndProcessOffer(request);
        if (success) {
            return ResponseEntity.ok("Offer placed successfully.");
        } else {
            return ResponseEntity.badRequest().body("Invalid offer request.");
        }
    }

    // Delete all offers for a given task
    @DeleteMapping("/task/{taskId}")
    public ResponseEntity<?> deleteOffers(@PathVariable Long taskId) {
        boolean deleted = offerService.deleteOffersForTask(taskId);
        if (deleted) {
            return ResponseEntity.ok("Offers deleted successfully.");
        } else {
            return ResponseEntity.status(500).body("Failed to delete offers.");
        }
    }

    // Update the status of an offer
    @PutMapping("/{offerId}/status")
    public ResponseEntity<?> updateOfferStatus(@PathVariable Long offerId, @RequestParam OfferStatus status) {
        boolean updated = offerService.updateOfferStatus(offerId, status);
        if (updated) {
            return ResponseEntity.ok("Offer status updated.");
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    // Accept a specific offer for a task
    @PutMapping("/{offerId}/accept")
    public ResponseEntity<?> acceptOffer(@RequestParam Long taskId,
                                         @PathVariable Long offerId,
                                         @RequestParam Long taskPosterId)
    {
        boolean accepted = offerService.acceptOffer(taskId, offerId,taskPosterId);
        if (accepted) {
            return ResponseEntity.ok("Offer accepted.");
        } else {
            return ResponseEntity.badRequest().body("Failed to accept offer.");
        }
    }
    //retrive offers placed by a certain runner
    @GetMapping("/runner/{runnerId}")
    public ResponseEntity<List<OfferResponse>> getOffersByRunner(@PathVariable Long runnerId) {
        List<OfferResponse> offers = offerService.getOffersByRunner(runnerId);
        return ResponseEntity.ok(offers);
    }
    //cancel offer
    @DeleteMapping("/{offerId}/cancel")
    public ResponseEntity<String> deleteOffer(@PathVariable Long offerId) {
        boolean deleted = offerService.cancelOffer(offerId);
        if (deleted) {
            return ResponseEntity.ok("Offer canceled successfully");
        } else {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Failed to cancel offer");
        }
    }

    /**
     * Endpoint to return number of offers for a given task
     */
    @GetMapping("/count/{taskId}")
    public ResponseEntity<Long> getOfferCount(@PathVariable Long taskId) {
        long count = offerService.getOfferCountForTask(taskId);
        return ResponseEntity.ok(count);
    }

    /**
     * Endpoint to check if a runner has already offered on a task
     */
    @GetMapping("/exists")
    public ResponseEntity<?> hasRunnerOffered(
            @RequestParam Long taskId,
            @RequestParam Long runnerId) {

        boolean exists = offerService.hasRunnerOffered(runnerId, taskId);

        if (!exists) {
            // ❌ Runner has not placed an offer — return 400 Bad Request
            return ResponseEntity
                    .badRequest()
                    .body("Runner has not placed an offer on this task.");
        }

        // ✅ Runner has placed an offer — return true
        return ResponseEntity.ok(true);
    }




    // Get all accepted task IDs for a given runner
    @GetMapping("/accepted/runner/{runnerId}")
    public ResponseEntity<List<TaskResponse>> getAcceptedOffersTasks(@PathVariable Long runnerId) {
        List<TaskResponse> tasks = offerService.getAcceptedOffersTasks(runnerId);
        return ResponseEntity.ok(tasks);
    }
}
