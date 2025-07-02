package com.gigs.task_service.model;
import com.fasterxml.jackson.databind.JsonNode;
import com.gigs.task_service.dto.request.TaskRequest;
import com.gigs.task_service.dto.response.TaskResponse;
import com.vladmihalcea.hibernate.type.json.JsonType;
import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.Type;

import java.time.LocalDateTime;

@Entity
@Inheritance(strategy = InheritanceType.JOINED)
public abstract class Task {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long taskId;

    private Long taskPoster;
    private String title;
    private String description;

    // Represents the category/type of task (e.g., moving, cleaning, event)
    private String type;

    private double longitude;
    private double latitude;

    @CreationTimestamp
    @Column(
            name = "created_date",
            columnDefinition = "datetime(6) default CURRENT_TIMESTAMP(6)",
            nullable = false,
            updatable = false
    )
    private LocalDateTime createdDate;

    public LocalDateTime getCreatedDate() {
        return createdDate;
    }

    @Type(JsonType.class)
    @Column(columnDefinition = "json") // Works for PostgreSQL & MySQL
    private JsonNode additionalRequirements;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TaskStatus status = TaskStatus.OPEN;


    // Constructors
    public Task() {}

    public Task(Long taskPoster, String title, String description, String type,
                double longitude, double latitude, JsonNode additionalRequirements) {
        this.taskPoster = taskPoster;
        this.title = title;
        this.description = description;
        this.type = type;
        this.longitude = longitude;
        this.latitude = latitude;
        this.additionalRequirements = additionalRequirements;
        this.status = (status != null) ? status : TaskStatus.OPEN;
    }
    public void updateCommonAttributes(TaskRequest taskRequest) {
        this.title = taskRequest.getTitle();
        this.description = taskRequest.getDescription();
        this.type = taskRequest.getType();
        this.longitude = taskRequest.getLongitude();
        this.latitude = taskRequest.getLatitude();
        this.additionalRequirements = taskRequest.getAdditionalRequirements();
    }


    public abstract void updateFromRequest(TaskRequest taskRequest);

    public abstract TaskResponse toDto();

    // Getters and Setters
    public Long getTaskId() { return taskId; }
    public void setTaskId(Long taskId) { this.taskId = taskId; }

    public Long getTaskPoster() { return taskPoster; }
    public void setTaskPoster(Long taskPoster) { this.taskPoster = taskPoster; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }

    public double getLatitude() { return latitude; }
    public void setLatitude(double latitude) { this.latitude = latitude; }

     public JsonNode getAdditionalRequirements() { return additionalRequirements; }
     public void setAdditionalRequirements(JsonNode additionalRequirements) { this.additionalRequirements = additionalRequirements; }

    public TaskStatus getStatus() {
        return status;
    }

    public void setStatus(TaskStatus status) {
        this.status = status;
    }

}
