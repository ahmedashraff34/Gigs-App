package com.gigs.task_service.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.gigs.task_service.client.MistralClient;
import com.gigs.task_service.client.payment.PaymentClient;
import com.gigs.task_service.client.payment.PaymentRequest;
import com.gigs.task_service.client.EventClient;
import com.gigs.task_service.client.OfferClient;
import com.gigs.task_service.client.UserClient;
import com.gigs.task_service.dto.request.TaskDynamicPriceRequest;
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
import jakarta.validation.ValidationException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.util.*;
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
    private final NotificationService notificationService;
    //Mo(for Ai/ML)
    private MistralClient mistralClient;
    @Autowired
    public TaskService(TaskRepository taskRepository, PaymentClient paymentClient, TaskFactoryProvider taskFactoryProvider, UserClient userClient,OfferClient offerClient,EventClient eventClient, DefaultValidationService validationService, NotificationService notificationService, MistralClient mistralClient) {
        this.taskRepository = taskRepository;
        this.paymentClient = paymentClient;
        this.taskFactoryProvider = taskFactoryProvider;
        this.userClient = userClient;
        this.offerClient = offerClient;
        this.eventClient=eventClient;
        this.validationService = validationService;
        this.notificationService = notificationService;
        this.mistralClient = mistralClient;
    }
    public TaskResponse createTask(TaskRequest taskRequest) {
        validationService.validateCreate(taskRequest);
        Task newTask = taskFactoryProvider.createTask(taskRequest);
        Task savedTask = taskRepository.save(newTask);
        
        // Send notification after task is successfully created
        notificationService.sendTaskCreatedNotification(
            savedTask.getTaskPoster(), 
            savedTask.getTaskId(), 
            savedTask.getTitle()
        );
        
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
        if (task.getStatus() == TaskStatus.COMPLETED ||task.getStatus() == TaskStatus.CANCELLED) {
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
                //Mark offer status as PAID (Mo new)
                try{
                    offerClient.updateOfferStatus(regularTask.getTaskId(),"PAID");
                }
                catch (Exception e){
                    System.err.println("Failed to update offer status: " + e.getMessage());

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
               // Mark event  applications as PAID
                try{
                    eventClient.updateApplicationStatus(eventTask.getTaskId(),"PAID");
                }catch (Exception e){
                    System.err.println("Failed to update application status: " + e.getMessage());
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

        // Send notification after task status is successfully updated
        notificationService.sendTaskStatusUpdateNotification(
            task.getTaskPoster(), 
            task.getTaskId(), 
            task.getTitle()
        );

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
        taskRepository.save(task);
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
        // MFROOOD NOTFICATION SERVICE B2A OR CLIENT Y3NY Y3RF EL RUNNER
        //notificationService.notifyRunnerAccepted(taskId, runnerId);

    }

    public boolean isInProgressWith(Long taskId, Long taskPosterId, Long runnerId) {
        return taskRepository.findById(taskId)
                .map(task -> {
                    if (task instanceof RegularTask rt) {
                        return rt.getStatus() == TaskStatus.IN_PROGRESS &&
                                rt.getTaskPoster().equals(taskPosterId) &&
                                rt.getRunnerId() != 0L &&
                                rt.getRunnerId() == runnerId &&
                                !runnerId.equals(taskPosterId);
                    } else if (task instanceof EventStaffingTask est) {
                        return true;
                    }
                    return false;
                })
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
    public void addRunnerToEventTask(Long taskId, Long runnerId, Long taskPosterId) {
        // 1) Verify that the task poster exists in the User Service
        if (!userClient.existsById(taskPosterId)) {
            throw new IllegalArgumentException("Task poster not found: " + taskPosterId);
        }

        // 2) Load the task from the DB
        Task t = taskRepository.findById(taskId)
                .orElseThrow(() -> new IllegalArgumentException("Task not found: " + taskId));

        // 3) Ensure the task is an EventStaffingTask
        if (!(t instanceof EventStaffingTask)) {
            throw new IllegalArgumentException("Task " + taskId + " is not an EventStaffingTask");
        }
        EventStaffingTask task = (EventStaffingTask) t;

        // 4) Ensure the given taskPosterId matches the actual task poster
        if (!task.getTaskPoster().equals(taskPosterId)) {
            throw new IllegalArgumentException("Provided taskPosterId does not match task owner");
        }

        // 5) Verify that the runner exists
        if (!userClient.existsById(runnerId)) {
            throw new IllegalArgumentException("Runner not found: " + runnerId);
        }

        // 6) Optional: check task status (uncomment if needed)
//    if (task.getStatus() != TaskStatus.OPEN) {
//        throw new IllegalStateException("Cannot add runner to a task that is " + task.getStatus());
//    }

        // 7) Prevent duplicate assignment
        if (task.getRunnerIds().contains(runnerId)) {
            throw new IllegalStateException("Runner " + runnerId + " is already assigned");
        }

        // 8) Check if task is already fully staffed
        if (task.getRunnerIds().size() >= task.getRequiredPeople()) {
            throw new IllegalStateException("Event is already fully staffed");
        }

        // 9) Assign the runner
        task.getRunnerIds().add(runnerId);

        taskRepository.save(task);

        // 10) Process payment reservation
        try {

            paymentClient.processPayment(new PaymentRequest(
                    task.getTaskPoster(),
                    runnerId,
                    taskId,
                    (long) task.getFixedPay()
            ));
        } catch (Exception e) {
            System.err.println("Failed to process payment for EventStaffingTask runner ID "
                    + runnerId + ": " + e.getMessage());
            throw new IllegalStateException("Payment processing failed, runner not added");
        }

        // 11) Save the updated task

    }

    @Transactional
    public void removeRunnerFromEventTask(Long taskId, Long runnerId, Long taskPosterId) {
        // 1) Verify that the task poster exists
        if (!userClient.existsById(taskPosterId)) {
            throw new IllegalArgumentException("Task poster not found: " + taskPosterId);
        }

        // 2) Load the task
        Task t = taskRepository.findById(taskId)
                .orElseThrow(() -> new IllegalArgumentException("Task not found: " + taskId));

        // 3) Ensure it's an EventStaffingTask
        if (!(t instanceof EventStaffingTask)) {
            throw new IllegalArgumentException("Task " + taskId + " is not an EventStaffingTask");
        }
        EventStaffingTask task = (EventStaffingTask) t;

        // 4) Check task poster match
        if (!task.getTaskPoster().equals(taskPosterId)) {
            throw new IllegalArgumentException("Provided taskPosterId does not match task owner");
        }

        // 5) Ensure runner exists
        if (!userClient.existsById(runnerId)) {
            throw new IllegalArgumentException("Runner not found: " + runnerId);
        }

        // 6) Confirm runner is assigned
        if (!task.getRunnerIds().contains(runnerId)) {
            throw new IllegalStateException("Runner " + runnerId + " is not assigned to this task");
        }

        // 7) Remove runner
        task.getRunnerIds().remove(runnerId);
        taskRepository.save(task);

        // 8) Call refund endpoint
        try {
            paymentClient.refundPayment(taskId,runnerId);
        } catch (Exception e) {
            System.err.println("Refund failed for task ID " + taskId + ": " + e.getMessage());
            throw new IllegalStateException("Refund processing failed, runner was removed");
        }
        //Mo fix
        try{
            eventClient.removeApplication(runnerId, taskId);
        }catch (Exception e){
            System.err.println("Failed to remove application for runner ID " + runnerId + ": " + e.getMessage());
        }
    }

    public List<TaskResponse> getOngoingTasksForPoster(Long posterId) {
        return taskRepository.findByTaskPosterAndStatus(posterId, TaskStatus.IN_PROGRESS)
                .stream()
                .map(Task::toDto)
                .collect(Collectors.toList());
    }



    //Mo (Ai/ML)
    public String suggestPrice(TaskDynamicPriceRequest task) {
        StringBuilder prompt = new StringBuilder();

        // Improved prompt with pricing bounds
        prompt.append("You are an AI pricing assistant for a task marketplace in Egypt. ");
        prompt.append("Based on the following task details, suggest a fair and reasonable price in Egyptian Pounds (EGP). ");
        prompt.append("The price must be affordable and realistic for a typical user. ");
        prompt.append("Return only a number between 50 and 1000 — no currency symbols, no extra text, no explanation.\n\n");

        // Add task details
        prompt.append("Title: ").append(task.getTitle()).append("\n");
        prompt.append("Type: ").append(task.getType()).append("\n");
        prompt.append("Description: ").append(task.getDescription()).append("\n\n");

        prompt.append("Additional Requirements:\n");
        prompt.append(formatJsonNode(task.getAdditionalRequirements()));

        prompt.append("Additional Attributes:\n");
        prompt.append(formatJsonNode(task.getAdditionalAttributes()));

        // Prepare the request
        Map<String, Object> requestBody = Map.of(
                "model", "mistral",
                "prompt", prompt.toString(),
                "stream", false
        );

        // Call mistral and parse the response
        String rawResponse = mistralClient.generatePrompt(requestBody);

        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode root = mapper.readTree(rawResponse);
            String priceText = root.get("response").asText().trim();

            // Try to parse price and apply bounds
            int price = Integer.parseInt(priceText.replaceAll("[^\\d]", "")); // remove any non-digit
            price = Math.max(50, Math.min(1000, price)); // clamp between 50–1000

            return String.valueOf(price);

        } catch (Exception e) {
            e.printStackTrace();
            return "Error";
        }
    }

    public String suggestDescription(TaskDynamicPriceRequest task) {
        StringBuilder prompt = new StringBuilder();

        // Strong prompt: max 3 sentences, no labels, no formatting
        prompt.append("You are an AI assistant that specializes in writing professional, clear, and concise task descriptions for a job marketplace. ");
        prompt.append("Based on the provided task details, generate a straight-to-the-point task description in a single well-written paragraph. ");
        prompt.append("Limit the response to a maximum of three sentences. ");
        prompt.append("Do NOT use bullet points, titles, or lists. Do NOT start with anything like 'Task:', 'Task Description:', 'Description:' or any label. ");
        prompt.append("Return ONLY the paragraph of the description — no headers, no labels, no extra text.\n\n");

        // Task details
        prompt.append("Title: ").append(task.getTitle()).append("\n");
        prompt.append("Type: ").append(task.getType()).append("\n");

        prompt.append("\nAdditional Requirements:\n");
        prompt.append(formatJsonNode(task.getAdditionalRequirements()));

        prompt.append("\nAdditional Attributes:\n");
        prompt.append(formatJsonNode(task.getAdditionalAttributes()));

        // Prepare request to Mistral model
        Map<String, Object> requestBody = Map.of(
                "model", "mistral",
                "prompt", prompt.toString(),
                "stream", false
        );

        // Call mistralClient and parse the response
        String rawResponse = mistralClient.generatePrompt(requestBody);

        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode root = mapper.readTree(rawResponse);

            // Extract the response and clean it from any unwanted prefixes
            return root.get("response")
                    .asText()
                    .trim()
                    .replaceFirst("^(?i)(Task Description:|Task:|Description:|Requirement:)\\s*", "")
                    .trim();
        } catch (Exception e) {
            e.printStackTrace();
            return "Error generating description.";
        }
    }


    private String formatJsonNode(JsonNode node) {
            if (node == null || node.isEmpty()) return "None provided.\n";

            StringBuilder formatted = new StringBuilder();
            node.fields().forEachRemaining(entry -> {
                String key = capitalize(entry.getKey().replace("_", " "));
                String value = entry.getValue().isTextual() ? entry.getValue().asText() : entry.getValue().toString();
                formatted.append("- ").append(key).append(": ").append(value).append("\n");
            });
            return formatted.toString();
        }

        private String capitalize(String str) {
            if (str == null || str.isEmpty()) return str;
            return str.substring(0, 1).toUpperCase() + str.substring(1);
        }

    public void instantDeleteTask(Long taskId) {
        // Validate taskId is not null
        if (taskId == null) {
            throw new ValidationException("Task ID cannot be null");
        }

        // Check if task exists
        if (!taskRepository.existsById(taskId)) {
            throw new ValidationException("Task not found");
        }

        // Delete the task immediately (admin override)
        taskRepository.deleteById(taskId);
    }
}





