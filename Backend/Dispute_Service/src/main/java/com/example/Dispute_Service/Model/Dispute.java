package com.example.Dispute_Service.Model;

import java.time.LocalDateTime;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;

@Entity
public class Dispute {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long disputeId;

    private Long taskId;
    private Long raisedBy;
    private String reason;
    private Long defendantId;

    @Enumerated(EnumType.STRING)
    private DisputeStatus status;

    @Lob
    private String images;

    private LocalDateTime createdAt;

    @Lob
    private String adminNotes;

    // No-args constructor
    public Dispute() {}

    // All-args constructor
    public Dispute(Long disputeId, Long taskId, Long raisedBy, String reason, Long defendantId,
                   DisputeStatus status, String images, LocalDateTime createdAt, String adminNotes) {
        this.disputeId = disputeId;
        this.taskId = taskId;
        this.raisedBy = raisedBy;
        this.reason = reason;
        this.defendantId = defendantId;
        this.status = status;
        this.images = images;
        this.createdAt = createdAt;
        this.adminNotes = adminNotes;
    }

    // Getters and Setters

    public Long getDisputeId() {
        return disputeId;
    }

    public void setDisputeId(Long disputeId) {
        this.disputeId = disputeId;
    }

    public Long getTaskId() {
        return taskId;
    }

    public void setTaskId(Long taskId) {
        this.taskId = taskId;
    }

    public Long getRaisedBy() {
        return raisedBy;
    }

    public void setRaisedBy(Long raisedBy) {
        this.raisedBy = raisedBy;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public Long getDefendantId() {
        return defendantId;
    }

    public void setDefendantId(Long defendantId) {
        this.defendantId = defendantId;
    }

    public DisputeStatus getStatus() {
        return status;
    }

    public void setStatus(DisputeStatus status) {
        this.status = status;
    }

    public String getImages() {
        return images;
    }

    public void setImages(String images) {
        this.images = images;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getAdminNotes() {
        return adminNotes;
    }

    public void setAdminNotes(String adminNotes) {
        this.adminNotes = adminNotes;
    }
}
