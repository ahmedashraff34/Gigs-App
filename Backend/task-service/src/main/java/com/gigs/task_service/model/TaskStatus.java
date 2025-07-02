package com.gigs.task_service.model;

public enum TaskStatus {
    OPEN,          // Task is newly created
    IN_PROGRESS,   // Task is assigned and being worked on
    DONE,          // Task is marked as done by el runner
    COMPLETED,     // Task is finished
    CANCELLED;
    public boolean canTransitionTo(TaskStatus newStatus) {
        return switch (this) {
            case OPEN -> newStatus == IN_PROGRESS || newStatus == CANCELLED;
            case IN_PROGRESS -> newStatus == DONE;
            case DONE -> newStatus == COMPLETED;
            case COMPLETED, CANCELLED -> false; // No further updates allowed
        };
    }
}
