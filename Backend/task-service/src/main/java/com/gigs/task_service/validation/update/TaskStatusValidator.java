package com.gigs.task_service.validation.update;

import com.gigs.task_service.model.Task;
import com.gigs.task_service.model.TaskStatus;
import com.gigs.task_service.repository.TaskRepository;
import com.gigs.task_service.validation.UpdateContext;
import com.gigs.task_service.validation.Validator;
import jakarta.validation.ValidationException;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

/**
 * Validator to prevent editing tasks that are completed, cancelled, or in progress.
 */
@Component
@Order(15)
public class TaskStatusValidator implements Validator<UpdateContext> {

    private final TaskRepository taskRepository;

    public TaskStatusValidator(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
    }

    @Override
    public void validate(UpdateContext context) {
        Task task = taskRepository.findById(context.getTaskId())
                .orElseThrow(() -> new ValidationException("Task not found"));
        TaskStatus status = task.getStatus();
        if (status == TaskStatus.COMPLETED
                || status == TaskStatus.CANCELLED
                || status == TaskStatus.IN_PROGRESS) {
            throw new ValidationException(
                    "Cannot edit a task that is already " + status
            );
        }
    }
}
