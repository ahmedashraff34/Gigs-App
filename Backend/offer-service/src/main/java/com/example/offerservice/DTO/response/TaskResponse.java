package com.example.offerservice.DTO.response;


import com.fasterxml.jackson.databind.JsonNode;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.LocalDateTime;

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
    //Regular task response related attributes :)
    private double amount;
    private JsonNode additionalAttributes;
    private LocalDateTime createdDate;

}