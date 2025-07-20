package com.gigs.task_service.validation.update;

import com.gigs.task_service.model.Task;
import com.gigs.task_service.validation.UpdateContext;
import com.gigs.task_service.validation.Validator;
import com.gigs.task_service.repository.TaskRepository;
import jakarta.validation.ValidationException;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

/**
 * Validator to ensure that the current TaskPoster is the owner of the task.
 */
@Component
@Order(10)
public class TaskOwnershipValidator implements Validator<UpdateContext> {

    private final TaskRepository taskRepository;

    public TaskOwnershipValidator(TaskRepository taskRepository) {
        this.taskRepository = taskRepository;
    }

    @Override
    public void validate(UpdateContext context) {
        Task task = taskRepository.findById(context.getTaskId())
                .orElseThrow(() -> new ValidationException("Task not found"));
        Long posterId = context.getRequest().getTaskPoster();
        if (!task.getTaskPoster().equals(posterId)) {
            throw new ValidationException("Only the TaskPoster can modify this task.");
        }
    }
}
