package com.gigs.task_service.controller;

import com.gigs.task_service.dto.request.TaskRequest;
import com.gigs.task_service.dto.response.ErrorResponse;
import com.gigs.task_service.dto.response.EventStaffingTaskResponse;
import com.gigs.task_service.dto.response.RegularTaskResponse;
import com.gigs.task_service.dto.response.TaskResponse;
import com.gigs.task_service.model.Task;
import com.gigs.task_service.model.TaskStatus;
import com.gigs.task_service.service.TaskService;
import jakarta.validation.Valid;
import jakarta.validation.ValidationException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

@RestController
@RequestMapping("/api/tasks")
public class TaskController {

    private final TaskService taskService;

    @Autowired
    public TaskController(TaskService taskService) {
        this.taskService = taskService;
    }

    @GetMapping("/all")
    public ResponseEntity<List<Task>> getAllTasks() {
        List<Task> tasks = taskService.getAllTasks();
        return ResponseEntity.ok(tasks);
    }

    @PostMapping("/postTask")
    public ResponseEntity<?> createTask(@Valid @RequestBody TaskRequest taskReq) {
        try {
            TaskResponse createdTask = taskService.createTask(taskReq);
            return ResponseEntity
                    .status(HttpStatus.CREATED)
                    .body(createdTask);

        } catch (IllegalArgumentException | ValidationException e) {
            // both our manual throws (IllegalArgument) and our Validator throws
            return ResponseEntity
                    .status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse(e.getMessage()));

        } catch (Exception e) {
            return ResponseEntity
                    .status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("An unexpected error occurred"));
        }
    }


    @GetMapping("/poster/{taskPosterId}")
    public ResponseEntity<List<Task>> getTasksByTaskPoster(@PathVariable Long taskPosterId) {
        List<Task> tasks = taskService.getTasksByTaskPoster(taskPosterId);
        return ResponseEntity.ok(tasks);
    }
    @PutMapping("edit/{taskId}")
    public ResponseEntity<?> updateTask(
            @PathVariable Long taskId,
            @Valid @RequestBody TaskRequest updatedTaskRequest) {
        try {
            TaskResponse updated = taskService.updateTask(taskId, updatedTaskRequest);
            return ResponseEntity.ok(updated);

        } catch (ValidationException e) {
            String msg = e.getMessage();
            if ("Task not found".equals(msg)) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(new ErrorResponse(msg));
            } else if (msg.startsWith("Only the TaskPoster")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse(msg));
            } else {
                return ResponseEntity.badRequest()
                        .body(new ErrorResponse(msg));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("An unexpected error occurred"));
        }
    }

    @DeleteMapping("delete/{taskId}")
    public ResponseEntity<?> deleteTask(
            @PathVariable Long taskId,
            @Valid @RequestBody TaskRequest deleteRequest
    ) {
        try {
            taskService.deleteTask(taskId, deleteRequest);
            return ResponseEntity.ok("Task deleted successfully.");
        } catch (ValidationException e) {
            String msg = e.getMessage();
            if ("Task not found".equals(msg)) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(new ErrorResponse(msg));
            } else if (msg.startsWith("Only the TaskPoster")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse(msg));
            } else {
                return ResponseEntity.badRequest()
                        .body(new ErrorResponse(msg));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("An unexpected error occurred"));
        }
    }
    @PutMapping("/{taskId}/status")
    public ResponseEntity<?> updateTaskStatus(
            @PathVariable Long taskId,
            @RequestParam TaskStatus newStatus,
            @RequestParam Long userId) {
        return taskService.updateTaskStatus(taskId, newStatus, userId);
    }

    @GetMapping("regular/{taskId}")
    public ResponseEntity<RegularTaskResponse> getRegularTaskById(@PathVariable Long taskId) {
        try {
            RegularTaskResponse resp = taskService.getRegularTaskById(taskId);
            return ResponseEntity.ok(resp);
        } catch (RuntimeException e) {
            String msg = e.getMessage();
            if (msg.startsWith("Task not found")) {
                // 404 when missing
                return ResponseEntity.notFound().build();
            } else if (msg.contains("is not a RegularTask")) {
                // 400 when wrong type
                return ResponseEntity.badRequest().build();
            } else {
                // fallback, still avoid 500 body
                return ResponseEntity.status(500).build();
            }
        }
    }

    @GetMapping("event/{taskId}")
    public ResponseEntity<EventStaffingTaskResponse> getEventTaskById(@PathVariable Long taskId) {
        try {
            EventStaffingTaskResponse resp = taskService.getEventTaskById(taskId);
            return ResponseEntity.ok(resp);
        } catch (RuntimeException e) {
            String msg = e.getMessage();
            if (msg.startsWith("Task not found")) {
                // 404 when missing
                return ResponseEntity.notFound().build();
            } else if (msg.contains("is not an EventStaffingTask")) {
                // 400 when wrong type
                return ResponseEntity.badRequest().build();
            } else {
                // fallback, still avoid 500 body
                return ResponseEntity.status(500).build();
            }
        }
    }


    @GetMapping("/{id}/exists")
    public ResponseEntity<Boolean> doesTaskExist(@PathVariable("id") Long id) {
        return ResponseEntity.ok(taskService.existsById(id));
    }

    @PutMapping("/{id}/accept")
    public ResponseEntity<?> acceptRegularTaskOffer(
            @PathVariable("id") Long taskId,
            @RequestParam("taskPosterId") Long taskPosterId,
            @RequestParam("runnerId") Long runnerId,
            @RequestParam double amount
    ) {
        try {
            taskService.acceptRegularTaskOffer(taskId, taskPosterId, runnerId, amount);
            return ResponseEntity.ok("Offer accepted successfully.");
        } catch (ValidationException e) {
            String msg = e.getMessage();
            if (msg.startsWith("RegularTask not found")) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(new ErrorResponse(msg));
            } else if (msg.startsWith("Only the TaskPoster")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse(msg));
            } else {
                return ResponseEntity.badRequest()
                        .body(new ErrorResponse(msg));
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("An unexpected error occurred"));
        }
    }

    @GetMapping("/{id}/verify-participants")
    public ResponseEntity<Boolean> verifyParticipantsAndStatus(
            @PathVariable("id") Long taskId,
            @RequestParam("taskPosterId") Long taskPosterId,
            @RequestParam("runnerId")    Long runnerId) {
        boolean ok = taskService.isInProgressWith(taskId, taskPosterId, runnerId);
        return ResponseEntity.ok(ok);
    }

    @GetMapping("/nearby")
    public ResponseEntity<List<TaskResponse>> getNearbyOpenTasks(
            @RequestParam double lat,
            @RequestParam double lon,
            @RequestParam double radius,
            @RequestParam Long userId     // the poster’s own ID
    ) {
        List<TaskResponse> list = taskService.getNearbyOpenTasks(
                lat, lon, radius, userId
        );
        return ResponseEntity.ok(list);
    }

    @GetMapping("/count")
    public ResponseEntity<Long> countTasksByStatusForUser(
            @RequestParam("userId") Long userId,
            @RequestParam("status") TaskStatus status
    ) {
        long count = taskService.countTasksByStatusForUser(userId, status);
        return ResponseEntity.ok(count);
    }

    @GetMapping("/regular/open")
    public List<RegularTaskResponse> openRegular(@RequestParam Long taskPosterId) {
        return taskService.getOpenRegularTasks(taskPosterId);
    }

    @GetMapping("/event/open")
    public List<EventStaffingTaskResponse> openEvent(@RequestParam Long taskPosterId) {
        return taskService.getOpenEventTasks(taskPosterId);
    }

    @PostMapping("/{taskId}/add-runner/{runnerId}")
    public ResponseEntity<Void> addRunnerToEventTask(
            @PathVariable Long taskId,
            @PathVariable Long runnerId) {
        try {
            taskService.addRunnerToEventTask(taskId, runnerId);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            // bad input, wrong type, runner or task not found
            return ResponseEntity.badRequest().build();
        } catch (IllegalStateException e) {
            // business rule violation: already full, already added, wrong status
            return ResponseEntity.status(409).build();
        }
    }

    @GetMapping("/poster/ongoing")
    public ResponseEntity<List<TaskResponse>> getOngoingForPoster(
            @RequestParam("taskPosterId") Long taskPosterId) {
        List<TaskResponse> list = taskService.getOngoingTasksForPoster(taskPosterId);
        return ResponseEntity.ok(list);
    }

}
