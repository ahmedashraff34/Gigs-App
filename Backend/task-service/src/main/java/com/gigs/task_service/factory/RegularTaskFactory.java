package com.gigs.task_service.factory;

import com.gigs.task_service.dto.request.RegularTaskRequest;
import com.gigs.task_service.dto.request.TaskRequest;
import com.gigs.task_service.model.RegularTask;
import com.gigs.task_service.model.Task;
import org.springframework.stereotype.Component;

@Component
public class RegularTaskFactory extends TaskFactory {
    @Override
    public boolean supports(TaskRequest taskRequest) {
        return taskRequest instanceof RegularTaskRequest;
    }

    @Override
    public Task createTask(TaskRequest taskRequest) {
        if (!(taskRequest instanceof RegularTaskRequest regularRequest)) {
            throw new IllegalArgumentException("Invalid task request for RegularTaskFactory");
        }

        return new RegularTask(
                regularRequest.getTaskPoster(),
                regularRequest.getTitle(),
                regularRequest.getDescription(),
                regularRequest.getType(),
                regularRequest.getLongitude(),
                regularRequest.getLatitude(),
                regularRequest.getAmount(),
                regularRequest.getAdditionalRequirements(),
                regularRequest.getAdditionalAttributes(),
                regularRequest.getImageUrls()
        );
    }
}
