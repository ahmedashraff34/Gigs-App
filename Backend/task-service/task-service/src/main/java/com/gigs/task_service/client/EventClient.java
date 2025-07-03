package com.gigs.task_service.client;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(
        name = "event-service"
)
public interface EventClient {
    @DeleteMapping(
            value="api/events/delete/{taskId}")
    void deleteApplicationsForTask(@PathVariable Long taskId);
}
