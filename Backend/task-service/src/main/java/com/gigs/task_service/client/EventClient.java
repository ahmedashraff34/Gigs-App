package com.gigs.task_service.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(
        name = "event-service"
)
public interface EventClient {
    @DeleteMapping(
            value="api/events/delete/{taskId}")
    void deleteApplicationsForTask(@PathVariable Long taskId);

    // Update the status of an offer
    @PutMapping(
            value = "api/events/update/all/{id}/")
    public void updateApplicationStatus(@PathVariable Long id, @RequestParam String status);

    @DeleteMapping("api/events/remove")
    public void removeApplication(@RequestParam Long runnerId, @RequestParam Long taskId);
}

