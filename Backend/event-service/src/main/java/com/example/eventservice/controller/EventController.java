package com.example.eventservice.controller;

import com.example.eventservice.DTO.request.EventRequest;
import com.example.eventservice.DTO.response.EventResponse;
import com.example.eventservice.DTO.response.TaskResponse;
import com.example.eventservice.model.ApplicationStatus;
import com.example.eventservice.service.EventService;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/events")
public class EventController {

    private final EventService eventService;

    @Autowired
    public EventController(EventService eventService) {
        this.eventService = eventService;
    }

    // POST /api/events/apply
    @PostMapping("/apply")
    public ResponseEntity<String> applyToEvent(@RequestBody EventRequest request) {
        boolean success = eventService.validateAndApply(request);
        if (success) {
            return ResponseEntity.ok("Application submitted successfully.");
        } else {
            return ResponseEntity.badRequest().body("Failed to apply to event task.");
        }
    }


    // DELETE /api/events/cancel
    @DeleteMapping("/cancel")
    public ResponseEntity<String> cancelApplication(@RequestParam Long runnerId, @RequestParam Long taskId) {
        boolean success = eventService.cancelApplication(runnerId, taskId);
        if(success) {
            return ResponseEntity.ok("Application cancelled successfully.");
        }   else {
            return ResponseEntity.badRequest().body("Failed to cancel application.");
        }
    }
    // DELETE /api/events/cancel
    @DeleteMapping("/remove")
    public ResponseEntity<String> removeApplication(@RequestParam Long runnerId, @RequestParam Long taskId) {
        boolean success = eventService.removeApplication(runnerId, taskId);
        if(success) {
            return ResponseEntity.ok("Application cancelled successfully.");
        }   else {
            return ResponseEntity.badRequest().body("Failed to cancel application.");
        }
    }

    // GET /api/events/runner/{runnerId}/tasks
    @GetMapping("/runner/{runnerId}/tasks")
    public List<TaskResponse> getTasksForRunner(@PathVariable Long runnerId) {
        return eventService.getTasksForRunner(runnerId);
    }

    // GET /api/events/task/{taskId}/applicants
    @GetMapping("/task/{taskId}/applicants")
    public List<EventResponse> getApplicantsForTask(@PathVariable Long taskId) {
        return eventService.getApplicantsForTask(taskId);
    }

    // PUT /api/events/approve/{applicationId}
    @PutMapping("/{taskPoster}/approve/{applicationId}")
    public ResponseEntity<String> approveApplication(
            @PathVariable Long taskPoster,
            @PathVariable Long applicationId) {
        boolean success = eventService.approveApplication(taskPoster, applicationId);
        if (success) {
            return ResponseEntity.ok("Runner approved and added to task.");
        } else {
            return ResponseEntity.badRequest().body("Failed to approve application.");
        }
    }
    // PUT
    @PutMapping("/update/{id}/")
    public ResponseEntity<?> updateApplicationStatus(
            @PathVariable Long id,
            @RequestParam ApplicationStatus status) {
        try {
            eventService.updateStatus(id, status);
            return ResponseEntity.ok("Status updated to " + status);
        } catch (EntityNotFoundException | IllegalStateException ex) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", ex.getMessage()));
        }
    }

    @PutMapping("/update/all/{id}/")
    public ResponseEntity<?> updateAllApplicationsStatus(
            @PathVariable Long id,
            @RequestParam ApplicationStatus status) {
        try {
            eventService.updateStatusForAllRunners(id, status);
            return ResponseEntity.ok("Status updated to " + status);
        } catch (EntityNotFoundException | IllegalStateException ex) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", ex.getMessage()));
        }
    }

    @GetMapping("/remaining-seats/{taskId}")
    public ResponseEntity<Integer> getRemainingSeats(@PathVariable Long taskId) {
        try {
            int remaining = eventService.getRemainingSeats(taskId);
            return ResponseEntity.ok(remaining);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build(); // returns 400 with empty body
        }
    }

    @GetMapping("/applications/runner/{runnerId}")
    public ResponseEntity<List<EventResponse>> getApplicationsByRunner(@PathVariable Long runnerId) {
        List<EventResponse> responses = eventService.getApplicationsByRunner(runnerId);
        return ResponseEntity.ok(responses);
    }

    @DeleteMapping("/delete/{taskId}")
    public ResponseEntity<String> deleteApplicationsForTask(@PathVariable Long taskId) {
        eventService.deleteAllApplicationsForTask(taskId);
        return ResponseEntity.ok("Applications deleted for task " + taskId);
    }

}
