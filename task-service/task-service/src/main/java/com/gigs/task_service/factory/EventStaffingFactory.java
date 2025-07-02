package com.gigs.task_service.factory;

import com.gigs.task_service.dto.request.EventStaffingRequest;
import com.gigs.task_service.dto.request.TaskRequest;
import com.gigs.task_service.model.EventStaffingTask;
import com.gigs.task_service.model.Task;
import org.springframework.stereotype.Component;

@Component
public class EventStaffingFactory extends TaskFactory {

    @Override
    public boolean supports(TaskRequest taskRequest) {
        return taskRequest instanceof EventStaffingRequest;
    }

    @Override
    public Task createTask(TaskRequest taskRequest) {
        if (!(taskRequest instanceof EventStaffingRequest eventRequest)) {
            throw new IllegalArgumentException("Invalid task request for EventStaffingFactory");
        }

        return new EventStaffingTask(
                eventRequest.getTaskPoster(),
                eventRequest.getTitle(),
                eventRequest.getDescription(),
                eventRequest.getType(),
                eventRequest.getLongitude(),
                eventRequest.getLatitude(),
                eventRequest.getLocation(),
                eventRequest.getFixedPay(),
                eventRequest.getRequiredPeople(),
                eventRequest.getAdditionalRequirements(),
                eventRequest.getStartDate(),
                eventRequest.getEndDate(),
                eventRequest.getNumberOfDays()
        );
    }
}
