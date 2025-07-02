package com.gigs.task_service.dto.response;

import com.fasterxml.jackson.databind.JsonNode;
import lombok.*;
import lombok.experimental.SuperBuilder;

@Data
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class TaskResponse {
    private Long taskId;
    private Long taskPoster;
    private String title;
    private String description;
    private String type;
    private double longitude;
    private double latitude;
    private JsonNode additionalRequirements;
    private String status;
}