package com.example.Dispute_Service.DTO;
import java.util.List;

public class CreateDisputeRequest {
    private Long taskId;
    private Long complainantId;
    private Long defendantId;
    private String reason;
    private List<String> evidenceUris;

    public Long getTaskId() {
        return taskId;
    }

    public void setTaskId(Long taskId) {
        this.taskId = taskId;
    }

    public Long getComplainantId() {
        return complainantId;
    }

    public void setComplainantId(Long complainantId) {
        this.complainantId = complainantId;
    }

    public Long getDefendantId() {
        return defendantId;
    }

    public void setDefendantId(Long defendantId) {
        this.defendantId = defendantId;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public List<String> getEvidenceUris() {
        return evidenceUris;
    }

    public void setEvidenceUris(List<String> evidenceUris) {
        this.evidenceUris = evidenceUris;
    }
}
