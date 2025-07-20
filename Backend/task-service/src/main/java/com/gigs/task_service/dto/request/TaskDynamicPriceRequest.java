package com.gigs.task_service.dto.request;

import com.fasterxml.jackson.databind.JsonNode;

public class TaskDynamicPriceRequest {
    private String title;
    private String description;
    private String type;
    private JsonNode additionalRequirements;
    private JsonNode additionalAttributes;

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public JsonNode getAdditionalRequirements() {
        return additionalRequirements;
    }

    public void setAdditionalRequirements(JsonNode additionalRequirements) {
        this.additionalRequirements = additionalRequirements;
    }

    public JsonNode getAdditionalAttributes() {
        return additionalAttributes;
    }

    public void setAdditionalAttributes(JsonNode additionalAttributes) {
        this.additionalAttributes = additionalAttributes;
    }
}
