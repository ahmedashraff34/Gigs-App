package com.gigs.task_service.validation.common;

import com.gigs.task_service.dto.request.TaskRequest;
import com.gigs.task_service.validation.Validator;
import com.gigs.task_service.client.UserClient;
import jakarta.validation.ValidationException;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

/**
 * Common validator to ensure the TaskPoster exists before any operation.
 */
@Component
@Order(5)
public class UserExistenceValidator implements Validator<TaskRequest> {

    private final UserClient userClient;

    public UserExistenceValidator(UserClient userClient) {
        this.userClient = userClient;
    }

    @Override
    public void validate(TaskRequest req) {
        Long posterId = req.getTaskPoster();
        if (posterId == null || !userClient.existsById(posterId)) {
            throw new ValidationException(
                    "TaskPoster with ID " + posterId + " does not exist.");
        }
    }
}
