package com.example.eventservice.client;

import com.example.eventservice.DTO.response.TaskResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@FeignClient(name = "task-service", path = "api/tasks")
public interface TaskClient {

    // Get a single task by its ID (used when getting the full details of one task)
    @GetMapping("/event/{taskId}")
    TaskResponse getEventTaskById(@PathVariable("taskId") Long taskId);
    // Add a runner to an EventStaffingTask
    @PostMapping("/{taskId}/add-runner/{runnerId}")
    void addRunnerToEventTask(@PathVariable("taskId") Long taskId,
                              @PathVariable("runnerId") Long runnerId,
                              @RequestParam Long taskPoster);

    // Remove a runner from an EventStaffingTask (not really needed)
    @DeleteMapping("/{taskId}/remove-runner/{runnerId}")
    void removeRunnerFromEventTask(@PathVariable("taskId") Long taskId,
                                   @PathVariable("runnerId") Long runnerId);
    @GetMapping("api/tasks/{id}/exists")
    Boolean doesTaskExist(@PathVariable("id") Long taskId);
}
