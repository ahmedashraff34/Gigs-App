package com.gigs.task_service.service;

import com.gigs.task_service.client.payment.PaymentClient;
import com.gigs.task_service.client.payment.PaymentRequest;
import com.gigs.task_service.client.EventClient;
import com.gigs.task_service.client.OfferClient;
import com.gigs.task_service.client.UserClient;
import com.gigs.task_service.dto.request.TaskRequest;
import com.gigs.task_service.dto.response.EventStaffingTaskResponse;
import com.gigs.task_service.dto.response.RegularTaskResponse;
import com.gigs.task_service.dto.response.TaskResponse;
import com.gigs.task_service.factory.TaskFactoryProvider;
import com.gigs.task_service.model.EventStaffingTask;
import com.gigs.task_service.model.RegularTask;
import com.gigs.task_service.model.Task;
import com.gigs.task_service.model.TaskStatus;
import com.gigs.task_service.repository.TaskRepository;
import com.gigs.task_service.validation.DefaultValidationService;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class TaskService {

    private final TaskRepository taskRepository;
    private final TaskFactoryProvider taskFactoryProvider;

    private final PaymentClient paymentClient;
    private final UserClient userClient;
    private final OfferClient offerClient;
    private final EventClient eventClient;
    private final DefaultValidationService validationService;
    @Autowired
    public TaskService(TaskRepository taskRepository, PaymentClient paymentClient, TaskFactoryProvider taskFactoryProvider, UserClient userClient,OfferClient offerClient,EventClient eventClient, DefaultValidationService validationService) {
        this.taskRepository = taskRepository;
        this.paymentClient = paymentClient;
        this.taskFactoryProvider = taskFactoryProvider;
        this.userClient = userClient;
        this.offerClient = offerClient;
        this.eventClient=eventClient;
        this.validationService = validationService;
    }
    public TaskResponse createTask(TaskRequest taskRequest) {
        validationService.validateCreate(taskRequest);
        Task newTask = taskFactoryProvider.createTask(taskRequest);
        Task savedTask = taskRepository.save(newTask);
        return savedTask.toDto();
    }

    public List<Task> getTasksByTaskPoster(Long taskPosterId) {
        return taskRepository.findByTaskPoster(taskPosterId);
    }

    public List<Task> getAllTasks(){
        return taskRepository.findAll();
    }

    // NO Validation SERVICE (ali)
    public RegularTaskResponse getRegularTaskById(Long id) {
        Task t = taskRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Task not found: " + id));
        if (!(t instanceof RegularTask)) {
            throw new RuntimeException("Task " + id + " is not a RegularTask");
        }
        return (RegularTaskResponse) t.toDto();
    }

    public EventStaffingTaskResponse getEventTaskById(Long taskId) {
        Task t = taskRepository.findById(taskId)
                .orElseThrow(() -> new RuntimeException("Task not found: " + taskId));
        if (!(t instanceof EventStaffingTask)) {
            throw new RuntimeException("Task " + taskId + " is not an event task");
        }
        // polymorphic: EventStaffingTask.toDto() returns EventStaffingTaskResponse
        return (EventStaffingTaskResponse) t.toDto();
    }


    public boolean existsById(Long id) {
        return taskRepository.existsById(id);
    }


    //lazm tt2kd mn el roles we en el user 7akeky -> update!!(msh btt2d en el user exists bs btt2ks eno lazm ykon el taskposter fa done (ali) )
    public TaskResponse updateTask(Long taskId, TaskRequest updatedTaskRequest) {
        validationService.validateUpdate(taskId, updatedTaskRequest);

        Task task = taskRepository.findById(taskId).get();
        task.updateFromRequest(updatedTaskRequest);
        Task saved = taskRepository.save(task);
        return saved.toDto();
    }

    public void deleteTask(Long taskId, TaskRequest deleteRequest) {
        try {
            validationService.validateDelete(taskId, deleteRequest);

            Optional<Task> optionalTask = taskRepository.findById(taskId);
            if (!optionalTask.isPresent()) {
                throw new RuntimeException("Task with ID " + taskId + " not found.");
            }

            Task task = optionalTask.get();

            if (task instanceof RegularTask) {
                offerClient.deleteOffers(taskId);
            } else if (task instanceof EventStaffingTask) {
                eventClient.deleteApplicationsForTask(taskId);
            }

            taskRepository.delete(task);
        } catch (Exception e) {
            System.err.println("Failed to delete task: " + e.getMessage());
            throw new RuntimeException("Could not delete task: " + e.getMessage(), e);
        }
    }


    //na2s yt2kd en el user exists
    public ResponseEntity<?> updateTaskStatus(Long taskId, TaskStatus newStatus, Long userId) {
        Optional<Task> taskOptional = taskRepository.findById(taskId);
        if (taskOptional.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("Task not found");
        }

        Task task = taskOptional.get();

        // Prevent updates on completed or cancelled or done tasks
        if (task.getStatus() == TaskStatus.COMPLETED || task.getStatus()== TaskStatus.DONE ||task.getStatus() == TaskStatus.CANCELLED) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Cannot update a task that is already " + task.getStatus());
        }

        // Check if the transition is valid
        if (!task.getStatus().canTransitionTo(newStatus)) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Invalid status transition: " + task.getStatus() + " → " + newStatus);
        }
        
        
        // ALL IN THE CASE OF TASK BEING of type REGULAR
        if(task instanceof RegularTask regularTask){
            // Ensure only runner can mark task as DONE
           if((newStatus == TaskStatus.DONE) && regularTask.getRunnerId() != userId){
               return ResponseEntity.status(HttpStatus.FORBIDDEN)
                       .body("Only the Runner can mark a task as done");
           } else if (newStatus == TaskStatus.DONE && regularTask.getRunnerId() == userId) {
               //update offer status
               try {
               offerClient.updateOfferStatus(regularTask.getTaskId(),"AWAITING_PAYMENT");
               }catch (Exception e){
                   System.err.println("Failed to update offer status: " + e.getMessage());
               }
           }
        }

        //Ensure TaskPoster only confirms completion and triggers PaymentClient
        //TODO : add paymentClient and test it
        if((newStatus == TaskStatus.COMPLETED) && !Objects.equals(task.getTaskPoster(), userId)){
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("Only the Task Poster can confirm completion");
        }
        else if (newStatus == TaskStatus.COMPLETED) {
            if (task instanceof RegularTask regularTask) {
                // payment release for runner
                try {
                    paymentClient.releasePayment(taskId, regularTask.getRunnerId());
                } catch (Exception e) {
                    System.err.println("Failed to release payment for RegularTask: " + e.getMessage());
                }
            } else if (task instanceof EventStaffingTask eventTask) {
                // payment release for each runner
                for (Long recipient : eventTask.getRunnerIds()) {
                    try {
                        paymentClient.releasePayment(taskId, recipient);
                    } catch (Exception e) {
                        System.err.println("Failed to release payment for recipient ID " + recipient + ": " + e.getMessage());
                    }
                }
            }
        }



        // Ensure the right user is making the update
        if (newStatus == TaskStatus.CANCELLED && !task.getTaskPoster().equals(userId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body("Only the TaskPoster can cancel a task");
        }
        // Update status
        task.setStatus(newStatus);
        taskRepository.save(task);

        return ResponseEntity.ok("Task status updated to " + newStatus);
    }

    public void acceptRegularTaskOffer(Long taskId, Long taskPosterId, Long runnerId, double amount) {
        // 1) load and verify it's a RegularTask
        RegularTask task = taskRepository.findById(taskId)
                .filter(t -> t instanceof RegularTask)
                .map(t -> (RegularTask) t)
                .orElseThrow(() -> new RuntimeException("RegularTask not found: " + taskId));

        /*
        // 2) Existence checks
        if (!userClient.existsById(taskPosterId)) {
            throw new RuntimeException("TaskPoster not found: " + taskPosterId);
        }
        if (!userClient.existsById(runnerId)) {
            throw new RuntimeException("Runner not found: " + runnerId);
        }
*/
        // 2) ensure caller is the poster
        if (!task.getTaskPoster().equals(taskPosterId)) {
            throw new RuntimeException("Only the TaskPoster can accept offers.");
        }
        // 3) ensure task is OPEN
        if (task.getStatus() != TaskStatus.OPEN) {
            throw new RuntimeException("Task must be OPEN to accept an offer.");
        }
        // 4) ensure task is not already accepted
        if (task.getRunnerId() != 0L) {
            throw new RuntimeException("An offer has already been accepted.");
        }
        // 5) ensure task runner is not same as task poster
        if (runnerId.equals(taskPosterId)) {
            throw new RuntimeException("TaskPoster cannot be the runner.");
        }

        if(amount <= 0){
            throw  new RuntimeException("amount must be greater than zero");
        }
        // 6) update status (e.g. to IN_PROGRESS)
        task.setStatus(TaskStatus.IN_PROGRESS);

        // 7) assign task to runner
        task.setRunnerId(runnerId);

        // 8) update amount to match el offer
        task.setAmount(amount);

        //TODO: 7ot el paymentClient.process  bel amount
        try {
            paymentClient.processPayment(new PaymentRequest(
                    taskPosterId,
                    runnerId,
                    taskId,
                    (long) amount
            ));
        } catch (Exception e) {
            System.err.println("Failed to process payment for RegularTask: " + e.getMessage());
        }
        taskRepository.save(task);
        // MFROOOD NOTFICATION SERVICE B2A OR CLIENT Y3NY Y3RF EL RUNNER
        //notificationService.notifyRunnerAccepted(taskId, runnerId);

    }


    public boolean isInProgressWith(Long taskId, Long taskPosterId, Long runnerId) {
        return taskRepository.findById(taskId)
                .filter(t -> t instanceof RegularTask)
                .map(t -> (RegularTask) t)
                .map(rt ->
                        rt.getStatus() == TaskStatus.IN_PROGRESS &&
                                rt.getTaskPoster() == taskPosterId &&
                                rt.getRunnerId() == runnerId &&
                                runnerId  != taskPosterId
                )
                .orElse(false);
    }


    public List<TaskResponse> getNearbyOpenTasks(
            double lat,
            double lon,
            double radius,
            Long requestingUserId
    ) {
        return taskRepository
                .findNearbyByStatusExcludingPoster(
                        TaskStatus.OPEN, lat, lon, radius, requestingUserId
                )
                .stream()
                .map(Task::toDto)
                .collect(Collectors.toList());
    }


    public long countTasksByStatusForUser(Long userId, TaskStatus status) {
        return taskRepository.countByTaskPosterAndStatus(userId, status);
    }

    public List<RegularTaskResponse> getOpenRegularTasks(Long posterId) {
        return taskRepository.findRegularTasksByPosterAndStatus(posterId, TaskStatus.OPEN)
                .stream()
                .map(Task::toDto)            // each RegularTask.toDto() returns a RegularTaskResponse
                .map(RegularTaskResponse.class::cast)
                .collect(Collectors.toList());
    }

    public List<EventStaffingTaskResponse> getOpenEventTasks(Long posterId) {
        return taskRepository.findEventTasksByPosterAndStatus(posterId, TaskStatus.OPEN)
                .stream()
                .map(Task::toDto)            // each EventStaffingTask.toDto() returns an EventStaffingTaskResponse
                .map(EventStaffingTaskResponse.class::cast)
                .collect(Collectors.toList());
    }

    @Transactional
    public void addRunnerToEventTask(Long taskId, Long runnerId) {
        // 1) load & type-check
        Task t = taskRepository.findById(taskId)
                .orElseThrow(() ->
                        new IllegalArgumentException("Task not found: " + taskId));
        if (!(t instanceof EventStaffingTask)) {
            throw new IllegalArgumentException(
                    "Task " + taskId + " is not an EventStaffingTask");
        }
        EventStaffingTask task = (EventStaffingTask) t;

        // 2) existance check
        if (!userClient.existsById(runnerId)) {
            throw new IllegalArgumentException(
                    "Runner not found: " + runnerId);
        }

        // 3) status check (shof nta 3yzha wla la -> ali)
//        if (task.getStatus() != TaskStatus.OPEN) {
//            throw new IllegalStateException(
//                    "Cannot add runner to a task that is " + task.getStatus());
//        }
        

        // 4) duplicate check
        if (task.getRunnerIds().contains(runnerId)) {
            throw new IllegalStateException(
                    "Runner " + runnerId + " is already assigned");
        }

        // 5) capacity check
        if (task.getRunnerIds().size() >= task.getRequiredPeople()) {
            throw new IllegalStateException(
                    "Event is already fully staffed");
        }

        // 6) assign & save
        task.getRunnerIds().add(runnerId);

        //TODO: 7ot paymentClient.process wel amount= task.fixedPay
        try {
            paymentClient.processPayment(new PaymentRequest(
                    task.getTaskPoster(),
                    runnerId,
                    taskId,
                    (long) task.getFixedPay()
            ));
        } catch (Exception e) {
            System.err.println("Failed to process payment for EventStaffingTask runner ID " + runnerId + ": " + e.getMessage());
        }

        taskRepository.save(task);
    }

    public List<TaskResponse> getOngoingTasksForPoster(Long posterId) {
        return taskRepository.findByTaskPosterAndStatus(posterId, TaskStatus.IN_PROGRESS)
                .stream()
                .map(Task::toDto)
                .collect(Collectors.toList());
    }



}
