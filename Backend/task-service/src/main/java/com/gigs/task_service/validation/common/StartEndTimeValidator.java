package com.gigs.task_service.validation.common;

import com.fasterxml.jackson.databind.JsonNode;
import com.gigs.task_service.dto.request.TaskRequest;
import com.gigs.task_service.validation.Validator;
import jakarta.validation.ValidationException;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
@Order(40)
public class StartEndTimeValidator implements Validator<TaskRequest> {
    @Override
    public void validate(TaskRequest req) {
        JsonNode json = req.getAdditionalRequirements();
        if (json != null && json.has("startTime") && json.has("endTime")) {
            LocalDateTime start = LocalDateTime.parse(json.get("startTime").asText());
            LocalDateTime end = LocalDateTime.parse(json.get("endTime").asText());
            if (!start.isBefore(end)) {
                throw new ValidationException("Start time must be before end time.");
            }
        }


    }
}
