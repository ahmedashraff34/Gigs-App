package com.gigs.task_service.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.time.LocalDate;
import java.util.List;

public class EventStaffingRequest extends TaskRequest {

    @NotNull(message = "Fixed pay is required for event staffing")
    @Positive(message = "Fixed pay must be greater than zero")
    private Double fixedPay;

    @NotNull(message = "Required people count is required")
    @Min(value = 1, message = "At least one person is required")
    private Integer requiredPeople;

    @NotBlank(message = "Location is required")
    private String location;

    @NotNull(message = "Start date is required")
    private LocalDate startDate;

    @NotNull(message = "End date is required")
    private LocalDate endDate;

    @NotNull(message = "Number of days is required")
    @Min(value = 1, message = "Number of days must be at least 1")
    private Integer numberOfDays;

    // Getters and Setters
    public Double getFixedPay() {
        return fixedPay;
    }

    public void setFixedPay(Double fixedPay) {
        this.fixedPay = fixedPay;
    }

    public Integer getRequiredPeople() {
        return requiredPeople;
    }

    public void setRequiredPeople(Integer requiredPeople) {
        this.requiredPeople = requiredPeople;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }
    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public void setEndDate(LocalDate endDate) {
        this.endDate = endDate;
    }

    public Integer getNumberOfDays() {
        return numberOfDays;
    }

    public void setNumberOfDays(Integer numberOfDays) {
        this.numberOfDays = numberOfDays;
    }
}
