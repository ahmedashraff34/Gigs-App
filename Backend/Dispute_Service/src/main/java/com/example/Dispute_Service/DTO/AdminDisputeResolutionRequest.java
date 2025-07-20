package com.example.Dispute_Service.DTO;

public class AdminDisputeResolutionRequest {
    private ResolutionType resolutionType;
    private String adminNotes;
    private Long recipientId; // Required for both RELEASE and REFUND resolution types

    // No-args constructor
    public AdminDisputeResolutionRequest() {}

    // All-args constructor
    public AdminDisputeResolutionRequest(ResolutionType resolutionType, String adminNotes, Long recipientId) {
        this.resolutionType = resolutionType;
        this.adminNotes = adminNotes;
        this.recipientId = recipientId;
    }

    // Getters and setters
    public ResolutionType getResolutionType() {
        return resolutionType;
    }

    public void setResolutionType(ResolutionType resolutionType) {
        this.resolutionType = resolutionType;
    }

    public String getAdminNotes() {
        return adminNotes;
    }

    public void setAdminNotes(String adminNotes) {
        this.adminNotes = adminNotes;
    }

    public Long getRecipientId() {
        return recipientId;
    }

    public void setRecipientId(Long recipientId) {
        this.recipientId = recipientId;
    }

    // Enum for resolution types
    public enum ResolutionType {
        RELEASE,  // Release payment to runner
        REFUND    // Refund payment to task poster
    }
}
