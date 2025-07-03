package com.gigs.payment_service.client;


import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

@FeignClient(
        name = "task-service"
)
public interface TaskClient {
    @GetMapping(value = "/api/tasks/{id}/verify-participants")
    ResponseEntity<Boolean> verifyParticipantsAndStatus(
            @PathVariable("id") Long taskId,
            @RequestParam("taskPosterId") Long taskPosterId,
            @RequestParam("runnerId")    Long runnerId);
    }
