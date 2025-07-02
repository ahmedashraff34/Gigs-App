package com.gigs.task_service.validation;

import com.gigs.task_service.dto.request.EventStaffingRequest;
import jakarta.validation.ValidationException;
import org.springframework.stereotype.Component;

@Component
public class EventStaffingTaskValidator implements Validator<EventStaffingRequest> {

    @Override
    public void validate(EventStaffingRequest r) {

        // 3. number of staff > 0
        if (r.getRequiredPeople() <= 0) {
            throw new ValidationException("Number of staff must be at least 1.");
        }
    }
}

