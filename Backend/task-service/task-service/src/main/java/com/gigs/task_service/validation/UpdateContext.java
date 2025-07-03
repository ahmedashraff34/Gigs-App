package com.gigs.task_service.validation;

import com.gigs.task_service.dto.request.TaskRequest;

public class UpdateContext {
    private final Long taskId;
    private final TaskRequest request;

    public UpdateContext(Long taskId, TaskRequest request) {
        this.taskId = taskId;
        this.request = request;
    }

    public Long getTaskId() {
        return taskId;
    }

    public TaskRequest getRequest() {
        return request;
    }
}
