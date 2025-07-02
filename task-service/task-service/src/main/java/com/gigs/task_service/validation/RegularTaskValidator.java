package com.gigs.task_service.validation;

import com.fasterxml.jackson.databind.JsonNode;
import com.gigs.task_service.dto.request.RegularTaskRequest;
import jakarta.validation.ValidationException;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Validator for RegularTaskRequest, enforcing rules specific to "REGULAR" tasks.
 */
@Component
@Order(50)  // runs after common validators
public class RegularTaskValidator implements Validator<RegularTaskRequest> {

    @Override
    public void validate(RegularTaskRequest req) {
        // 1. amount must be provided and > 0
        if (req.getAmount() == null || req.getAmount() <= 0) {
            throw new ValidationException("Amount must be greater than zero.");
        }

        JsonNode attrs = req.getAdditionalAttributes();
        // 3. numeric-attribute prefixes: keys starting with "number" must be non-negative numbers
        Iterator<String> keys = attrs.fieldNames();
        while (keys.hasNext()) {
            String key = keys.next();
            if (key.toLowerCase().startsWith("number")) {
                JsonNode node = attrs.get(key);
                if (!node.isNumber() || node.asDouble() < 0) {
                    throw new ValidationException(
                            "Attribute '" + key + "' must be a non-negative number.");
                }
            }
        }

        if (attrs.has("startTime") && attrs.has("endTime")) {
            LocalDateTime start = LocalDateTime.parse(attrs.get("startTime").asText());
            LocalDateTime end = LocalDateTime.parse(attrs.get("endTime").asText());
            if (!start.isBefore(end)) {
                throw new ValidationException("Start time must be before end time.");
            }
        }


        if (attrs != null) {
            // 2. pickup/dropoff pairing: any key containing "pickup" must have a corresponding "dropoff"
            Iterator<String> fieldNames = attrs.fieldNames();
            List<String> pickupKeys = new ArrayList<>();
            List<String> dropoffKeys = new ArrayList<>();
            while (fieldNames.hasNext()) {
                String key = fieldNames.next();
                String lower = key.toLowerCase();
                if (lower.contains("pickup")) pickupKeys.add(key);
                if (lower.contains("dropoff")) dropoffKeys.add(key);
            }
            if (!pickupKeys.isEmpty() && dropoffKeys.isEmpty()) {
                throw new ValidationException("At least one dropoff attribute must be provided when pickup is set.");
            }
            if (pickupKeys.isEmpty() && !dropoffKeys.isEmpty()) {
                throw new ValidationException("At least one pickup attribute must be provided when dropoff is set.");
            }
            // match pairs and ensure values differ
            for (String pKey : pickupKeys) {
                String suffix = pKey.substring(pKey.toLowerCase().indexOf("pickup") + "pickup".length());
                String expectedDrop = "dropoff" + suffix;
                String actualDrop = dropoffKeys.stream()
                        .filter(d -> d.equalsIgnoreCase(expectedDrop))
                        .findFirst().orElse(null);
                if (actualDrop == null) {
                    throw new ValidationException("Missing dropoff attribute for '" + pKey + "'.");
                }
                String pickVal = attrs.get(pKey).asText();
                String dropVal = attrs.get(actualDrop).asText();
                if (pickVal.equals(dropVal)) {
                    throw new ValidationException(
                            "Values for '" + pKey + "' and '" + actualDrop + "' must not be the same.");
                }
            }


        }
    }
}