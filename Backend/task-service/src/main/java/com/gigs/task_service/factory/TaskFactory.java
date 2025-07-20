package com.gigs.task_service.factory;

import com.gigs.task_service.dto.request.TaskRequest;
import com.gigs.task_service.model.Task;

public abstract class TaskFactory {
    public abstract boolean supports(TaskRequest taskRequest);
    public abstract Task createTask(TaskRequest taskRequest);
}
