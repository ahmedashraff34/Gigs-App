package com.gigs.task_service.model;

import com.fasterxml.jackson.databind.JsonNode;
import com.gigs.task_service.dto.request.RegularTaskRequest;
import com.gigs.task_service.dto.request.TaskRequest;
import com.gigs.task_service.dto.response.RegularTaskResponse;
import com.gigs.task_service.dto.response.TaskResponse;
import com.vladmihalcea.hibernate.type.json.JsonType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import org.hibernate.annotations.Type;

import java.util.List;

@Entity
public class RegularTask extends Task {

    private double amount;

    @Type(JsonType.class)
    @Column(columnDefinition = "json")
    private JsonNode additionalAttributes;

    public long getRunnerId() {
        return runnerId;
    }

    public void setRunnerId(long runnerId) {
        this.runnerId = runnerId;
    }

    //for offers zwdha fl constructor b3d ama t3ml el offer-service
    private long runnerId;

    public RegularTask() {}

    public RegularTask(Long taskPoster, String title, String description, String type,
                       double longitude, double latitude, double amount, JsonNode additionalRequirements, JsonNode additionalAttributes,List<String> imageUrls) {
        super(taskPoster, title, description, type, longitude, latitude,additionalRequirements,imageUrls);
        this.amount = amount;
        this.additionalAttributes = additionalAttributes;
    }
    @Override
    public void updateFromRequest(TaskRequest taskRequest) {
        if (taskRequest instanceof RegularTaskRequest regularRequest) {
            updateCommonAttributes(regularRequest);
            this.amount = regularRequest.getAmount();
            this.additionalAttributes = regularRequest.getAdditionalAttributes();
        }
    }

    @Override
    public TaskResponse toDto() {
        return RegularTaskResponse.builder()
                .taskId(getTaskId())
                .imageUrls(getImageUrls())
                .taskPoster(getTaskPoster())
                .title(getTitle())
                .description(getDescription())
                .type(getType())
                .longitude(getLongitude())
                .latitude(getLatitude())
                .status(getStatus().name())
                .additionalRequirements(getAdditionalRequirements())
                .amount(getAmount())
                .additionalAttributes(getAdditionalAttributes())
                .runnerId(getRunnerId())
                .createdDate(getCreatedDate())
                .build();
    }


    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }

     public JsonNode getAdditionalAttributes() { return additionalAttributes; }
     public void setAdditionalAttributes(JsonNode additionalAttributes) { this.additionalAttributes = additionalAttributes; }
}
