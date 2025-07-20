package com.example.eventservice.DTO.response;

import com.fasterxml.jackson.databind.JsonNode;
import lombok.*;
import lombok.experimental.SuperBuilder;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

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
    //Event Staffing task response related attributes :)
    private String location;
    private double fixedPay;
    private int requiredPeople;
    //for time constraints
    private LocalDateTime createdDate;
    private LocalDate startDate;
    private LocalDate endDate;
    //for possibly QR
    private int numberOfDays;

}