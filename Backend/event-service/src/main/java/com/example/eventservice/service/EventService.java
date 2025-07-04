package com.example.eventservice.service;

import com.example.eventservice.DTO.request.EventRequest;
import com.example.eventservice.DTO.response.EventResponse;
import com.example.eventservice.DTO.response.TaskResponse;
import com.example.eventservice.client.TaskClient;
import com.example.eventservice.client.UserClient;
import com.example.eventservice.model.ApplicationStatus;
import com.example.eventservice.model.EventApplication;
import com.example.eventservice.repository.EventApplicationRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class EventService {

    private final EventApplicationRepository applicationRepo;
    private final TaskClient taskClient;
    private final UserClient userClient;

    @Autowired
    public EventService(EventApplicationRepository applicationRepo, TaskClient taskClient, UserClient userClient) {
        this.applicationRepo = applicationRepo;
        this.taskClient = taskClient;
        this.userClient = userClient;
    }

    /**
     * Validates and processes a new event application.
     * Ensures the task exists, the applicant hasn't applied before, and the required people limit isn't exceeded.
     */
    public boolean validateAndApply(EventRequest req) {
        if (req.getTaskId() == null || req.getApplicantId() == null) {
            return false;
        }
        try{
            // ✅ Check if user exists (optional cross-service validation)
            if(!userClient.existsById(req.getApplicantId())){
                return false;
            }
        }catch (Exception e){
            System.err.println("Failed to check if user exits: "+e.getMessage());
        }

        try {

        // 🛑 Reject duplicate applications
        boolean alreadyApplied = applicationRepo.existsByApplicantIdAndEventTask(req.getApplicantId(), req.getTaskId());
        if (alreadyApplied) return false;

        // ✅ Confirm task exists
        TaskResponse newTask = taskClient.getEventTaskById(req.getTaskId());
        if (newTask == null) return false;

        // 🧮 Check capacity
        List<EventApplication> currentApplications = applicationRepo.findByEventTask(req.getTaskId());
        if (currentApplications.size() >= newTask.getRequiredPeople()) return false;

        // ⏳ Check time conflict with other applications
        List<EventApplication> applicantApplications = applicationRepo.findByApplicantId(req.getApplicantId());

        for (EventApplication app : applicantApplications) {
            // Skip same task (already checked for duplicates above)
            if (app.getEventTask().equals(req.getTaskId())) continue;

            TaskResponse existingTask = taskClient.getEventTaskById(app.getEventTask());

            if (existingTask == null) continue;

            // Null-safe fallback
            LocalDate newStart = newTask.getStartDate();
            LocalDate newEnd = newTask.getEndDate() != null ? newTask.getEndDate() : newStart;

            LocalDate existingStart = existingTask.getStartDate();
            LocalDate existingEnd = existingTask.getEndDate() != null ? existingTask.getEndDate() : existingStart;

            boolean overlap = (newStart.isBefore(existingEnd.plusDays(1)) && newEnd.isAfter(existingStart.minusDays(1)));

            if (overlap) {
                // 🛑 Found overlapping task
                return false;
            }
        }
        }catch (Exception e){
            System.err.println("Failed to retrieve task: "+e.getMessage());
        }
        // ✅ Proceed to apply
        applyToEventTask(req);
        return true;
    }

    /**
     * Actually stores the application in the DB.
     * Sets default status to PENDING.
     */
    public EventApplication applyToEventTask(EventRequest req) {
        EventApplication app = new EventApplication();
        app.setApplicantId(req.getApplicantId());
        app.setEventTask(req.getTaskId());
        app.setComment(req.getComment());
        app.setProfileResumeLink(req.getResumeLink());
        app.setStatus(ApplicationStatus.PENDING); // ✅ Default state
        return applicationRepo.save(app);
    }

    /**
     * Cancels an application by runner & taskId.
     * Deletes the DB entry and removes the runner from the task's assigned list.
     */
    public boolean cancelApplication(Long runnerId, Long taskId) {
        Optional<EventApplication> optionalApp = applicationRepo.findByApplicantIdAndEventTask(runnerId, taskId);
        if (optionalApp.isEmpty()) return false;
        if(optionalApp.get().getStatus()!=ApplicationStatus.PENDING) return false;
        applicationRepo.delete(optionalApp.get());
       // taskClient.removeRunnerFromEventTask(taskId, runnerId);

        return true;
    }

    /**
     * Returns all event tasks a runner has applied to (excluding WITHDRAWN).
     */
    public List<TaskResponse> getTasksForRunner(Long runnerId) {
        return applicationRepo.findByApplicantId(runnerId)
                .stream()
                .filter(app -> app.getStatus() != ApplicationStatus.WITHDRAWN) // 🧹 Skip withdrawn
                .map(EventApplication::getEventTask)
                .distinct()
                .map(taskClient::getEventTaskById)
                .collect(Collectors.toList());
    }

    /**
     * Gets all applicants (with DTOs) for a specific task.
     * WITHDRAWN ones are excluded.
     */
    public List<EventResponse> getApplicantsForTask(Long taskId) {
        return applicationRepo.findByEventTask(taskId)
                .stream()
                .filter(app -> app.getStatus() != ApplicationStatus.WITHDRAWN)
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    /**
     * Accepts/approves an application (status = APPROVED).
     * Also notifies the task-service to add the runner to the task's internal list.
     */
    public boolean approveApplication(Long taskPoster,Long applicationId) {
        Optional<EventApplication> optional = applicationRepo.findById(applicationId);
        if (optional.isEmpty()) return false;

        EventApplication app = optional.get();

        if (app.getStatus() == ApplicationStatus.APPROVED) return false; // Already approved

        // ✅ Update status and save
        app.setStatus(ApplicationStatus.APPROVED);
        applicationRepo.save(app);

        // 🔁 Notify task-service to assign runner
        try {
            taskClient.addRunnerToEventTask(app.getEventTask(), app.getApplicantId(),taskPoster);
        } catch (Exception e) {
            System.err.println("Failed to notify task-service: " + e.getMessage());
            return false;
        }

        return true;
    }
    //update application status
    public void updateStatus(Long applicationId, ApplicationStatus newStatus) {
        EventApplication app = applicationRepo.findById(applicationId)
                .orElseThrow(() -> new EntityNotFoundException("Application not found"));

        if (app.getStatus() == newStatus) {
            throw new IllegalStateException("Status already set to " + newStatus);
        }

        app.setStatus(newStatus);
        applicationRepo.save(app);
    }
    // delete all applications for a task

    public void deleteAllApplicationsForTask(Long taskId) {
        List<EventApplication> apps=applicationRepo.findByEventTask(taskId);
        applicationRepo.deleteAll(apps);

    }
    //retrieve remaining seats for an event
    public int getRemainingSeats(Long taskId) {
    try {
        TaskResponse task = taskClient.getEventTaskById(taskId);
        if (task == null) return 0;
        long acceptedCount = applicationRepo.countAcceptedApplicationsByTaskId(taskId);
        return task.getRequiredPeople() - (int) acceptedCount;
    }catch (Exception e){
        System.err.println(e.getMessage());
    }
    return 0;
    }

    public List<EventResponse> getApplicationsByRunner(Long runnerId) {
        List<EventApplication> apps = applicationRepo.findByApplicantId(runnerId);
        return apps.stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());
    }

    /**
     * Converts an EventApplication entity into a DTO for response.
     */
    public EventResponse mapToDto(EventApplication app) {
        return EventResponse.builder()
                .applicationId(app.getApplicationId())
                .applicantId(app.getApplicantId())
                .taskId(app.getEventTask())
                .comment(app.getComment())
                .status(app.getStatus())
                .resumeLink(app.getProfileResumeLink())
//                .videoUrl(app.getVideoUrl())
                .profilePic("Profile Pic Placeholder")         // Will later be fetched from user-service
                .applicantName("Runner Name Placeholder")
                .build();
    }
}
