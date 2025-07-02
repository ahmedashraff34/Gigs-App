package com.gigs.task_service.dto.response;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.experimental.SuperBuilder;

import java.time.LocalDate;
import java.util.List;

@Data
@EqualsAndHashCode(callSuper = true)
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
public class EventStaffingTaskResponse extends TaskResponse {

    private String location;
    private double fixedPay;
    private int requiredPeople;
    private List<Long> runnerIds;
    private LocalDate startDate;
    private LocalDate endDate;
    private int numberOfDays;

}
