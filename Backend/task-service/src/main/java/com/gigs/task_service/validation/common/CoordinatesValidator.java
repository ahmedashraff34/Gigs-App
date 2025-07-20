package com.gigs.task_service.validation.common;

import com.gigs.task_service.dto.request.TaskRequest;
import com.gigs.task_service.validation.Validator;
import jakarta.validation.ValidationException;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

/**
 * Ensures coordinates are within Egypt’s bounding box.
 */
@Component
@Order(10)
public class CoordinatesValidator implements Validator<TaskRequest> {
    private static final double MIN_LAT = 22.0, MAX_LAT = 31.5;
    private static final double MIN_LON = 24.0, MAX_LON = 36.0;

    @Override
    public void validate(TaskRequest req) {
        Double lat = req.getLatitude();
        Double lon = req.getLongitude();
        if (lat == null || lon == null
                || lat < MIN_LAT || lat > MAX_LAT
                || lon < MIN_LON || lon > MAX_LON) {
            throw new ValidationException("Coordinates must be within Egypt’s bounds.");
        }
    }
}
