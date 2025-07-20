package com.example.eventservice.model;

import jakarta.persistence.*;

import lombok.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EventApplication {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long applicationId;
    private Long eventTask;
    private Long applicantId;
    private String comment;

    @Enumerated(EnumType.STRING)
    private ApplicationStatus status;

    private String profileResumeLink;
    private String videoUrl;
}
