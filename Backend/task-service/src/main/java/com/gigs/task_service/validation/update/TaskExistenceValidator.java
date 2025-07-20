package com.gigs.task_service.validation.update;

import com.gigs.task_service.validation.UpdateContext;
import com.gigs.task_service.validation.Validator;
import com.gigs.task_service.repository.TaskRepository;
import jakarta.validation.ValidationException;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

/**
 * Validator to ensure that a task with the given ID exists.
 */
@Component
@Order(5)
public class TaskExistenceValidator implements Validator<UpdateContext> {

    private final TaskRepository taskRepository;

    public TaskExistenceValidator(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
    }

    @Override
    public void validate(UpdateContext context) {
        if (taskRepository.findById(context.getTaskId()).isEmpty()) {
            throw new ValidationException("Task not found");
        }
    }
}
