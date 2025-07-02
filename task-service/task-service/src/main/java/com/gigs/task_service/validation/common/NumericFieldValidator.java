package com.gigs.task_service.validation.common;

import com.fasterxml.jackson.databind.JsonNode;
import com.gigs.task_service.dto.request.TaskRequest;
import com.gigs.task_service.validation.Validator;
import jakarta.validation.ValidationException;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.Iterator;

/**
 * Ensures any numeric field in additionalRequirements is positive (> 0).
 */
@Component
@Order(20)
public class NumericFieldValidator implements Validator<TaskRequest> {
    @Override
    public void validate(TaskRequest req) {
        JsonNode json = req.getAdditionalRequirements();
        if (json != null) {
            Iterator<String> it = json.fieldNames();
            while (it.hasNext()) {
                String field = it.next();
                JsonNode node = json.get(field);
                if (node.isNumber() && node.asDouble() <= 0) {
                    throw new ValidationException(
                            "Numeric field '" + field + "' must be greater than zero.");
                }
            }
        }
    }
}