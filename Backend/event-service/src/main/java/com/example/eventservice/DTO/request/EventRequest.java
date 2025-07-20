package com.example.eventservice.DTO.request;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EventRequest {
    private Long taskId;
    private Long applicantId;
    private String resumeLink;
    private String comment;
}
