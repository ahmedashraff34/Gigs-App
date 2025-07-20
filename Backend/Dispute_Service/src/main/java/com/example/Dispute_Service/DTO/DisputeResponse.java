package com.example.Dispute_Service.DTO;

import com.example.Dispute_Service.Model.Dispute;
import com.example.Dispute_Service.Model.DisputeStatus;

import java.time.LocalDateTime;
import java.util.List;

public class DisputeResponse {
    private Long disputeId;
    private Long taskId;
    private Long raisedBy;
    private String complainantName;
    private Long defendantId;
    private String defendantName;
    private String reason;
    private DisputeStatus status;
    private List<String> evidenceUrls;
    private LocalDateTime createdAt;
    private String adminNotes;

    // No-args constructor
    public DisputeResponse() {}

    // All-args constructor
    public DisputeResponse(Long disputeId, Long taskId, Long raisedBy, String complainantName,
                           Long defendantId, String defendantName, String reason, DisputeStatus status,
                           List<String> evidenceUrls, LocalDateTime createdAt, String adminNotes) {
        this.disputeId = disputeId;
        this.taskId = taskId;
        this.raisedBy = raisedBy;
        this.complainantName = complainantName;
        this.defendantId = defendantId;
        this.defendantName = defendantName;
        this.reason = reason;
        this.status = status;
        this.evidenceUrls = evidenceUrls;
        this.createdAt = createdAt;
        this.adminNotes = adminNotes;
    }

    // Static factory method from Dispute entity
    public static DisputeResponse fromDispute(Dispute dispute) {
        DisputeResponse response = new DisputeResponse();
        response.setDisputeId(dispute.getDisputeId());
        response.setTaskId(dispute.getTaskId());
        response.setRaisedBy(dispute.getRaisedBy());
        response.setDefendantId(dispute.getDefendantId());
        response.setReason(dispute.getReason());
        response.setStatus(dispute.getStatus());
        response.setCreatedAt(dispute.getCreatedAt());
        response.setAdminNotes(dispute.getAdminNotes());

        if (dispute.getImages() != null && !dispute.getImages().isEmpty()) {
            response.setEvidenceUrls(List.of(dispute.getImages().split(",")));
        }

        return response;
    }

    // Getters and setters
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

    public String getComplainantName() {
        return complainantName;
    }

    public void setComplainantName(String complainantName) {
        this.complainantName = complainantName;
    }

    public Long getDefendantId() {
        return defendantId;
    }

    public void setDefendantId(Long defendantId) {
        this.defendantId = defendantId;
    }

    public String getDefendantName() {
        return defendantName;
    }

    public void setDefendantName(String defendantName) {
        this.defendantName = defendantName;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public DisputeStatus getStatus() {
        return status;
    }

    public void setStatus(DisputeStatus status) {
        this.status = status;
    }

    public List<String> getEvidenceUrls() {
        return evidenceUrls;
    }

    public void setEvidenceUrls(List<String> evidenceUrls) {
        this.evidenceUrls = evidenceUrls;
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
