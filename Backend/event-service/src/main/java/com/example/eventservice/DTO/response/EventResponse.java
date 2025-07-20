package com.example.eventservice.DTO.response;

import com.example.eventservice.model.ApplicationStatus;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EventResponse {
    private Long applicationId;
    private Long applicantId;
    private String applicantName;
    private Long taskId;
    private String comment;
    private ApplicationStatus status;
    private String resumeLink;
    private String profilePic;
    private String videoUrl;
}
