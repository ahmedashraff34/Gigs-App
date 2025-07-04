package com.example.Dispute_Service.Client;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@FeignClient(
        name = "task-service",
        url = "${task.service.url:http://localhost:8081}",
        fallback = TaskClientFallback.class
)
public interface TaskClient {

    @GetMapping("/api/tasks/{id}/exists")
    Boolean existsById(@PathVariable("id") long id);

}


