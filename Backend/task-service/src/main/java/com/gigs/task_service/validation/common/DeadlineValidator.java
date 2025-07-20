package com.gigs.task_service.validation.common;

import com.fasterxml.jackson.databind.JsonNode;
import com.gigs.task_service.dto.request.TaskRequest;
import com.gigs.task_service.validation.Validator;
import jakarta.validation.ValidationException;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * Validates that any "deadline" field in additionalRequirements is in the future.
 */
@Component
@Order(30)
public class DeadlineValidator implements Validator<TaskRequest> {
    @Override
    public void validate(TaskRequest req) {
        JsonNode json = req.getAdditionalRequirements();
        if (json != null && json.has("deadline")) {
            LocalDateTime dl = LocalDateTime.parse(json.get("deadline").asText());
            if (dl.isBefore(LocalDateTime.now())) {
                throw new ValidationException("Deadline must be in the future.");
            }
        }
    }
}