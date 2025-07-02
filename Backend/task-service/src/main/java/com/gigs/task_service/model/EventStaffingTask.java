package com.gigs.task_service.model;

import com.fasterxml.jackson.databind.JsonNode;
import com.gigs.task_service.dto.request.EventStaffingRequest;
import com.gigs.task_service.dto.request.TaskRequest;
import com.gigs.task_service.dto.response.EventStaffingTaskResponse;
import com.gigs.task_service.dto.response.TaskResponse;
import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;

import java.time.LocalDate;
import java.util.List;

@Entity
public class EventStaffingTask extends Task {

    @Column(nullable = false)
    private String location;

    @Column(nullable = false)
    private double fixedPay;

    @Column(nullable = false)
    private int requiredPeople;

    @ElementCollection
    private List<Long> runnerIds;

    @Column
    private LocalDate startDate;

    @Column
    private LocalDate endDate;

    @Column(nullable = false)
    private int numberOfDays;

    public EventStaffingTask() {}

    public EventStaffingTask(Long taskPoster,
                             String title,
                             String description,
                             String type,
                             double longitude,
                             double latitude,
                             String location,
                             double fixedPay,
                             int requiredPeople,
                             JsonNode additionalRequirements,
                             LocalDate startDate,
                             LocalDate endDate,
                             int numberOfDays) {
        super(taskPoster, title, description, type, longitude, latitude, additionalRequirements);
        this.location = location;
        this.fixedPay = fixedPay;
        this.requiredPeople = requiredPeople;
        this.startDate = startDate;
        this.endDate = endDate;
        this.numberOfDays = numberOfDays;
    }

    @Override
    public void updateFromRequest(TaskRequest taskRequest) {
        if (taskRequest instanceof EventStaffingRequest eventRequest) {
            updateCommonAttributes(eventRequest);
            this.location = eventRequest.getLocation();
            this.fixedPay = eventRequest.getFixedPay();
            this.requiredPeople = eventRequest.getRequiredPeople();
            this.startDate = eventRequest.getStartDate();
            this.endDate = eventRequest.getEndDate();
            this.numberOfDays = eventRequest.getNumberOfDays();
        }
    }

    @Override
    public TaskResponse toDto() {
        return EventStaffingTaskResponse.builder()
                .taskId(getTaskId())
                .taskPoster(getTaskPoster())
                .title(getTitle())
                .description(getDescription())
                .type(getType())
                .longitude(getLongitude())
                .latitude(getLatitude())
                .status(getStatus().name())
                .additionalRequirements(getAdditionalRequirements())
                .location(location)
                .fixedPay(fixedPay)
                .requiredPeople(requiredPeople)
                .runnerIds(runnerIds)
                .startDate(startDate)
                .endDate(endDate)
                .numberOfDays(numberOfDays)
                .build();
    }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public double getFixedPay() { return fixedPay; }
    public void setFixedPay(double fixedPay) { this.fixedPay = fixedPay; }
    public int getRequiredPeople() { return requiredPeople; }
    public void setRequiredPeople(int requiredPeople) { this.requiredPeople = requiredPeople; }
    public List<Long> getRunnerIds() { return runnerIds; }
    public void setRunnerIds(List<Long> runnerIds) { this.runnerIds = runnerIds; }
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }
    public int getNumberOfDays() { return numberOfDays; }
    public void setNumberOfDays(int numberOfDays) { this.numberOfDays = numberOfDays; }
}
