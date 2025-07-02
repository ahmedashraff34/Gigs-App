package com.gigs.task_service.validation;

import com.gigs.task_service.dto.request.TaskRequest;

public interface ValidationService {
    void validateCreate(TaskRequest req);
    void validateUpdate(Long taskId, TaskRequest req);
    void validateDelete(Long taskId, TaskRequest req);



}
