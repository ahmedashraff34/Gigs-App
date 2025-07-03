package com.gigs.task_service.dto.request;

import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.fasterxml.jackson.databind.JsonNode;
import jakarta.persistence.Lob;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, property = "task_type")
@JsonSubTypes({
        @JsonSubTypes.Type(value = RegularTaskRequest.class, name = "REGULAR"),
        @JsonSubTypes.Type(value = EventStaffingRequest.class, name = "EVENT")
})
public abstract class TaskRequest {

    @NotBlank(message = "Title is required")
    private String title;

    @NotBlank(message = "Description is required")
    private String description;

    @NotBlank(message = "Task category (type) is required")
    private String type; // Represents task category (e.g., moving, cleaning, event)

    @NotNull(message = "Task poster ID is required")
    private Long taskPoster;

    @NotNull(message = "Longitude is required")
    private Double longitude;

    @NotNull(message = "Latitude is required")
    private Double latitude;

    @Lob
    private JsonNode additionalRequirements;

    // Getters and Setters
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public Long getTaskPoster() { return taskPoster; }
    public void setTaskPoster(Long taskPoster) { this.taskPoster = taskPoster; }

    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }

    public double getLatitude() { return latitude; }
    public void setLatitude(double latitude) { this.latitude = latitude; }

    public JsonNode getAdditionalRequirements() {
        return additionalRequirements;
    }

    public void setAdditionalRequirements(JsonNode additionalRequirements) {
        this.additionalRequirements = additionalRequirements;
    }
}
