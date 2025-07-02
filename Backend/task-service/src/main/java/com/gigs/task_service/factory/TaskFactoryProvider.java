package com.gigs.task_service.factory;


import com.gigs.task_service.dto.request.TaskRequest;
import com.gigs.task_service.model.Task;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class TaskFactoryProvider {

    private final List<TaskFactory> factories;

    public TaskFactoryProvider(List<TaskFactory> factories) {
        this.factories = factories;
    }

    public Task createTask(TaskRequest taskRequest) {
        return factories.stream()
                .filter(factory -> factory.supports(taskRequest))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("No factory found for task type: " + taskRequest.getClass().getSimpleName()))
                .createTask(taskRequest);
    }
}
